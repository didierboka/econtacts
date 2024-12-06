//
//  ContactManagerCoreData.swift
//  E-Contacts
//
//  Created by M. Didier BOKA on 04/12/2024.
//

import Foundation
import CoreData


class ContactManagerCoreData {
    
    
    static let shared = ContactManagerCoreData()
    
    

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ContactModelCoreData")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("❌ Erreur Core Data:", error)
            }
        }
        return container
    }()
    
    private var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    private init() {}
    

    func saveContact(_ contact: ContactModel) throws {
        let fetchRequest: NSFetchRequest<ContactEntity> = ContactEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", contact.email)
        
        // Check if exist
        let existingContact = try? context.fetch(fetchRequest).first
        let contactEntity = existingContact ?? ContactEntity(context: context)
        
        // Update data
        contactEntity.email = contact.email
        contactEntity.phone = contact.phone
        contactEntity.cell = contact.cell
        contactEntity.firstName = contact.name.first
        contactEntity.lastName = contact.name.last
        contactEntity.pictureUrl = contact.picture.large
        
        contactEntity.street = "\(contact.location.street.number) \(contact.location.street.name)"
        contactEntity.city = contact.location.city
        contactEntity.state = contact.location.state
        contactEntity.country = contact.location.country
        contactEntity.postcode = contact.location.postcode.stringValue
        
        contactEntity.lastUpdated = Date()
        try context.save()
    }
    
    
    func fetchContacts(offset: Int, limit: Int) throws -> [ContactEntity] {
        let fetchRequest: NSFetchRequest<ContactEntity> = ContactEntity.fetchRequest()
        fetchRequest.fetchOffset = offset
        fetchRequest.fetchLimit = limit
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastName", ascending: true)]
        
        return try context.fetch(fetchRequest)
    }
    
    
    func searchContacts(query: String) throws -> [ContactEntity] {
        let fetchRequest: NSFetchRequest<ContactEntity> = ContactEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "firstName CONTAINS[cd] %@ OR lastName CONTAINS[cd] %@ OR email CONTAINS[cd] %@",
            query, query, query
        )
        return try context.fetch(fetchRequest)
    }
    
    
    func deleteAllContacts() throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ContactEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(deleteRequest)
        try context.save()
    }
}


extension ContactEntity {
    
    // Convert Entity to Model
    func toContactModel() -> ContactModel {
        let name = NameModel(
            title: "",
            first: firstName ?? "",
            last: lastName ?? ""
        )
        
        let picture = PictureModel(
            large: pictureUrl ?? "",
            medium: pictureUrl ?? "",
            thumbnail: pictureUrl ?? ""
        )
        
        let street = StreetModel(
            number: Int(street?.components(separatedBy: " ").first ?? "0") ?? 0,
            name: street?.components(separatedBy: " ").dropFirst().joined(separator: " ") ?? ""
        )
        
        
        let location = LocationModel(
            street: street,
            city: city ?? "",
            state: state ?? "",
            country: country ?? "",
            postcode: PostalCode(postcode ?? ""),
            coordinates: CoordinatesModel(latitude: "", longitude: ""),
            timezone: TimezoneModel(offset: "", description: "")
        )
        
        return ContactModel(
            gender: "",
            name: name,
            location: location,
            email: email ?? "",
            phone: phone ?? "",
            cell: cell ?? "",
            picture: picture,
            nat: ""
        )
    }
}
