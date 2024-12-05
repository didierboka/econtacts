//
//  ContactNameModel.swift
//  E-Contacts
//
//  Created by M. Didier BOKA on 04/12/2024.
//

import Foundation


// Sous-structures pour organiser les informations
struct ContactNameModel : Codable {
    let title: String
    let first: String
    let last: String
    
    // Fonction utilitaire pour obtenir le nom complet
    var fullName: String {
        return "\(first) \(last)"
    }
}
