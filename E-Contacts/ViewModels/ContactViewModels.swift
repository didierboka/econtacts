//
//  ContactViewModels.swift
//  E-Contacts
//
//  Created by M. Didier BOKA on 04/12/2024.
//

import Foundation


class ContactViewModels {
    
    
    // MARK: - Properties
    private(set) var contacts: [ContactModel] = []
    private(set) var filteredContacts: [ContactModel] = []
    private var currentPage = 0
    private let pageSize = 50
    private(set) var isLoading = false
    private var hasMoreData = true
    private var currentSearchText: String = ""
    
    
    // MARK: - Closures
    var onContactsFetched: (() -> Void)?
    var onError: ((Error) -> Void)?
    var onLoading: ((Bool) -> Void)?
    
    
    // MARK: - Methods
    func loadInitialContacts() {
        guard !isLoading else { return }
        currentPage = 0
        contacts.removeAll()
        filteredContacts.removeAll()
        hasMoreData = true
        currentSearchText = ""
        
        onContactsFetched?()
        fetchContacts(count: pageSize)
    }
    
    
    func loadMoreIfNeeded(currentIndex: Int) {
        let thresholdIndex = contacts.count - 15
        if currentIndex > thresholdIndex && !isLoading && hasMoreData {
            print("SIZING => \(currentIndex)")
            
            fetchContacts(count: pageSize)
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
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Status Code:", httpResponse.statusCode)
            }
            
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.onLoading?(false)
                
                if let error = error {
                    print("❌ Erreur:", error.localizedDescription)
                    self?.onError?(error)
                    return
                }
                
                guard let data = data else {
                    print("⚠️ Pas de données reçues")
                    self?.onError?(NSError(domain: "No data received", code: -2))
                    return
                }
                
                do {
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("📥 JSON reçu:", jsonString)
                    }
                    
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .useDefaultKeys
                    
                    do {
                        let response = try decoder.decode(ContactResponseModel.self, from: data)
                        print("✅ Décodage réussi")
                        
                        // Vérifie s'il y a plus de données à charger
                        self?.hasMoreData = response.results.count == count
                        
                        self?.contacts.append(contentsOf: response.results)
                        self?.filterContacts(with: self?.currentSearchText ?? "") // Réappliquer le filtre actuel
                        self?.currentPage += 1
                        self?.onContactsFetched?()
                        
                    } catch let decodingError as DecodingError {
                        print("🔴 Erreur de décodage détaillée:", decodingError)
                        switch decodingError {
                        case .keyNotFound(let key, let context):
                            print("Clé manquante:", key, "Context:", context)
                        case .typeMismatch(let type, let context):
                            print("Type incorrect:", type, "Context:", context)
                        case .valueNotFound(let type, let context):
                            print("Valeur manquante:", type, "Context:", context)
                        case .dataCorrupted(let context):
                            print("Données corrompues:", context)
                        @unknown default:
                            print("Erreur inconnue:", decodingError)
                        }
                        self?.onError?(decodingError)
                    }
                } catch {
                    print("🔴 Erreur générale:", error)
                    self?.onError?(error)
                }
            }
        }
        
        task.resume()
    }
    
    
    func refreshContacts() {
        // Protéger contre les appels multiples
        guard !isLoading else { return }
        
        // Reset tout d'abord
        DispatchQueue.main.async { [weak self] in
            self?.currentPage = 0
            self?.contacts.removeAll()
            self?.hasMoreData = true
            
            // Notifier que la liste est vide
            self?.onContactsFetched?()
            
            // Puis lancer le chargement
            self?.fetchContacts(count: self?.pageSize ?? 50)
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
