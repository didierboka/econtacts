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
    private var currentPage = 0
    
    // MARK: - Closures
    var onContactsFetched: (() -> Void)?
    var onError: ((Error) -> Void)?
    var onLoading: ((Bool) -> Void)?
    
    
    // MARK: - Methods
    func fetchContacts(count: Int = 10) {
        onLoading?(true)
        
        print("https://randomuser.me/api/?results=\(count)&page=\(currentPage)")
        
        let urlString = "https://randomuser.me/api/?results=\(count)&page=\(currentPage)"
        guard let url = URL(string: urlString) else {
            onError?(NSError(domain: "Invalid URL", code: -1))
            onLoading?(false)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Status Code:", httpResponse.statusCode)  // Log du status code
            }
            
            DispatchQueue.main.async {
                self?.onLoading?(false)
                
                if let error = error {
                    print("❌ Erreur:", error.localizedDescription)  // Log des erreurs
                    self?.onError?(error)
                    return
                }
                
                guard let data = data else {
                    print("⚠️ Pas de données reçues")
                    self?.onError?(NSError(domain: "No data received", code: -2))
                    return
                }
                
                do {
                    // D'abord, affichons les données brutes reçues
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("📥 JSON reçu:", jsonString)
                    }
                    
                    let decoder = JSONDecoder()
                    // Ajoutons une configuration supplémentaire au décodeur
                    decoder.keyDecodingStrategy = .useDefaultKeys
                    
                    do {
                        let response = try decoder.decode(ContactResponseModel.self, from: data)
                        print("✅ Décodage réussi")
                        self?.contacts.append(contentsOf: response.results)
                        self?.currentPage += 1
                        self?.onContactsFetched?()
                    } catch let decodingError as DecodingError {
                        // Affichons plus de détails sur l'erreur de décodage
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
        currentPage = 0
        contacts.removeAll()
        fetchContacts()
    }
}
