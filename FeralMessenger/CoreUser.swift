//
//  CoreUser.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/27/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import CoreData
import Parse


class CoreUser: NSManagedObject {
    
    static let entityName = String(describing: CoreUser.self)
    static let usernameSortDescriptor = NSSortDescriptor(key: "username", ascending: true)
    static let createdSortDescriptor = NSSortDescriptor(key: "created_at", ascending: false, selector: #selector(NSString.localizedCompare(_:)))
    
    static var defaultFetchedRequest: NSFetchRequest<CoreUser> {
        let request = NSFetchRequest<CoreUser>(entityName: entityName)
        request.fetchLimit = 100
        request.sortDescriptors = [usernameSortDescriptor]
        return request
    }
    
    class func sortedFetchRequest(with predicate: NSPredicate?) -> NSFetchRequest<CoreUser> {
        let request = NSFetchRequest<CoreUser>(entityName: entityName)
        request.fetchLimit = 500
        request.sortDescriptors = [NSSortDescriptor(key: "username", ascending: true)]
        if let predicate = predicate {
            request.predicate = predicate
        }
        return request
    }
    
    // if found a match -> return the same one from the data store, if a match is not found -> create
    class func findOrCreateCoreUser(matching pfObject: PFObject, in context: NSManagedObjectContext) throws -> CoreUser {
        let request: NSFetchRequest<CoreUser> = CoreUser.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", pfObject.objectId!)
        do {
            let matches = try context.fetch(request) // returning as [CoreUser]
            if matches.count > 0 {
                assert(matches.count == 1, "CoreMessage.findOrCreateCoreMessage - database inconsistency")
                return matches[0]
            }
        } catch {
            throw error
        }
        let coreUser = CoreUser(context: context)
        guard let id = pfObject.objectId, let email = pfObject["email"] as? String, let profileImage = pfObject["profile_image"] as? String, let timezone = pfObject["timezone"] as? String, let username = pfObject["username"] as? String, let uuid = pfObject["uuid"] as? String else {
            fatalError("findOrCreateCoreUser: - failed to parse PFObject")
        }
        coreUser.id = id as String
        coreUser.email = email
        coreUser.profile_image = profileImage
        coreUser.timezone = timezone
        coreUser.username = username
        coreUser.uuid = uuid
        return coreUser
    }

}














