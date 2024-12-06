//
//  ContactModel.swift
//  E-Contacts
//
//  Created by M. Didier BOKA on 04/12/2024.
//

import Foundation



// MARK: - Contact Response
struct ContactResponseModel: Codable {
    let results: [ContactModel]
    let info: APIInfoModel
}


// MARK: - API Info
struct APIInfoModel: Codable {
    let seed: String
    let results: Int
    let page: Int
    let version: String
}


// MARK: - Contact
struct ContactModel: Codable {
    let gender: String
    let name: NameModel
    let location: LocationModel
    let email: String
    let phone: String
    let cell: String
    let picture: PictureModel
    let nat: String
}


// MARK: - Name
struct NameModel: Codable {
    let title: String
    let first: String
    let last: String
    
    var fullName: String {
        return "\(first) \(last)"
    }
}


// MARK: - Location
struct LocationModel: Codable {
    let street: StreetModel
    let city: String
    let state: String
    let country: String
    let postcode: PostalCode
    let coordinates: CoordinatesModel
    let timezone: TimezoneModel
}


// MARK: - Street
struct StreetModel: Codable {
    let number: Int
    let name: String
}

// MARK: - Coordinates
struct CoordinatesModel: Codable {
    let latitude: String
    let longitude: String
}

// MARK: - Timezone
struct TimezoneModel: Codable {
    let offset: String
    let description: String
}

// MARK: - Picture
struct PictureModel: Codable {
    let large: String
    let medium: String
    let thumbnail: String
}


// Enum for parse PostalCode can be a String or an Int
enum PostalCode: Codable {
    case string(String)
    case int(Int)
    
    // Pour le décodage
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else {
            throw DecodingError.typeMismatch(
                PostalCode.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected string or integer value"
                )
            )
        }
    }
    
    // Ajout d'un initialiseur avec String
    init(_ value: String) {
        self = .string(value)
    }
    
    
    // Ajout d'un initialiseur avec Int
    init(_ value: Int) {
        self = .int(value)
    }
    
    // After parse transform to String
    var stringValue: String {
        switch self {
        case .string(let value): return value
        case .int(let value): return String(value)
        }
    }
}
