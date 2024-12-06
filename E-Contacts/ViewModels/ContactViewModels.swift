//
//  ContactViewModels.swift
//  E-Contacts
//
//  Created by M. Didier BOKA on 04/12/2024.
//

import Foundation
import Reachability


class ContactViewModels {
    // MARK: - Properties
    private(set) var contacts: [ContactModel] = []
    private(set) var filteredContacts: [ContactModel] = []
    private var currentPage = 0
    private let pageSize = 50
    private(set) var isLoading = false
    private var hasMoreData = true
    private var currentSearchText: String = ""
    private let coreDataManager = ContactManagerCoreData.shared
    private let networkMonitor = NetworkMonitorService.shared
    
    // MARK: - Closures
    var onContactsFetched: (() -> Void)?
    var onError: ((Error) -> Void)?
    var onLoading: ((Bool) -> Void)?
    
    init() {
        setupNetworkMonitoring()
    }
    
    private func setupNetworkMonitoring() {
        networkMonitor.onConnectionRestored = { [weak self] in
            if self?.contacts.isEmpty == true {
                self?.loadInitialContacts()
            }
        }
    }
    
    // MARK: - Methods
    func loadInitialContacts() {
        guard !isLoading else { return }
        currentPage = 0
        contacts.removeAll()
        filteredContacts.removeAll()
        hasMoreData = true
        currentSearchText = ""
        
        // Charger d'abord les données locales
        loadLocalContacts()
        
        // Si en ligne, charger les données fraîches
        if networkMonitor.isConnected {
            fetchContacts(count: pageSize)
        }
    }
    
    private func loadLocalContacts() {
        do {
            let localContacts = try coreDataManager.fetchContacts(offset: currentPage * pageSize, limit: pageSize)
            contacts = localContacts.map { $0.toContactModel() }
            filterContacts(with: currentSearchText)
            onContactsFetched?()
        } catch {
            print("🔴 Erreur lors du chargement des contacts locaux:", error)
        }
    }
    
    private func fetchContacts(count: Int = 50) {
        guard !isLoading, hasMoreData else { return }
        
        isLoading = true
        onLoading?(true)
        
        let urlString = "https://randomuser.me/api/?results=\(count)&page=\(currentPage)"
        guard let url = URL(string: urlString) else {
            onError?(NSError(domain: "Invalid URL", code: -1))
            onLoading?(false)
            isLoading = false
            return
        }
        
        print("📥 Fetching page \(currentPage) with \(count) contacts")
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.handleAPIResponse(data: data, response: response, error: error)
            }
        }
        
        task.resume()
    }
    
    private func handleAPIResponse(data: Data?, response: URLResponse?, error: Error?) {
        isLoading = false
        onLoading?(false)
        
        if let error = error {
            print("❌ Erreur:", error.localizedDescription)
            // En cas d'erreur réseau, utiliser les données locales si disponibles
            if contacts.isEmpty {
                loadLocalContacts()
            }
            onError?(error)
            return
        }
        
        guard let data = data else {
            print("⚠️ Pas de données reçues")
            onError?(NSError(domain: "No data received", code: -2))
            return
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            
            let response = try decoder.decode(ContactResponseModel.self, from: data)
            print("✅ Décodage réussi")
            
            // Sauvegarder en local
            for contact in response.results {
                try? coreDataManager.saveContact(contact)
            }
            
            hasMoreData = response.results.count == pageSize
            contacts.append(contentsOf: response.results)
            filterContacts(with: currentSearchText)
            currentPage += 1
            onContactsFetched?()
            
        } catch let decodingError as DecodingError {
            handleDecodingError(decodingError)
        } catch {
            print("🔴 Erreur générale:", error)
            onError?(error)
        }
    }
    
    private func handleDecodingError(_ error: DecodingError) {
        print("🔴 Erreur de décodage détaillée:", error)
        switch error {
        case .keyNotFound(let key, let context):
            print("Clé manquante:", key, "Context:", context)
        case .typeMismatch(let type, let context):
            print("Type incorrect:", type, "Context:", context)
        case .valueNotFound(let type, let context):
            print("Valeur manquante:", type, "Context:", context)
        case .dataCorrupted(let context):
            print("Données corrompues:", context)
        @unknown default:
            print("Erreur inconnue:", error)
        }
        onError?(error)
    }
    
    func loadMoreIfNeeded(currentIndex: Int) {
        let thresholdIndex = contacts.count - 15
        if currentIndex > thresholdIndex && !isLoading && hasMoreData {
            if networkMonitor.isConnected {
                fetchContacts(count: pageSize)
            } else {
                loadLocalContacts()
            }
        }
    }
    
    func refreshContacts() {
        guard !isLoading else { return }
        
        if networkMonitor.isConnected {
            currentPage = 0
            contacts.removeAll()
            hasMoreData = true
            onContactsFetched?()
            fetchContacts(count: pageSize)
        } else {
            onError?(NSError(
                domain: "Offline",
                code: -3,
                userInfo: [NSLocalizedDescriptionKey: "Pas de connexion internet. Affichage des données locales."]
            ))
            loadLocalContacts()
        }
    }
    
    func filterContacts(with searchText: String) {
        currentSearchText = searchText.lowercased()
        
        if currentSearchText.isEmpty {
            filteredContacts = contacts
        } else {
            filteredContacts = contacts.filter { contact in
                contact.name.fullName.lowercased().contains(currentSearchText) ||
                contact.email.lowercased().contains(currentSearchText)
            }
        }
        
        onContactsFetched?()
    }
}
