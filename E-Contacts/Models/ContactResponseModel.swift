//
//  ContactResponseModel.swift
//  E-Contacts
//
//  Created by M. Didier BOKA on 05/12/2024.
//

import Foundation


// MARK: - Contact Response
struct ContactResponseModel: Codable {
    let results: [ContactModel]
    let info: APIInfo
}
