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
    static let usernameSortDescriptor = NSSortDescriptor(key: "username", ascending: true, selector: nil)
    static let createdSortDescriptor = NSSortDescriptor(key: "created_at", ascending: false, selector: #selector(NSString.localizedCompare(_:)))
    
    class func defaultFetchRequest(with predicate: NSPredicate?) -> NSFetchRequest<CoreUser> {
        let request = NSFetchRequest<CoreUser>(entityName: entityName)
        request.fetchLimit = 300
        request.sortDescriptors = [usernameSortDescriptor, createdSortDescriptor]
        if let predicate = predicate {
            request.predicate = predicate
        }
        return request
    }
    
    class func findOrCreateCoreUser(matching pfObject: PFObject, in context: NSManagedObjectContext) throws -> CoreUser {
        let request: NSFetchRequest<CoreUser> = CoreUser.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", pfObject.objectId!)
        do {
            let matches = try context.fetch(request) // returning as [CoreUser]
            if matches.count > 0 {
                assert(matches.count == 1, "CoreMessage.findOrCreateCoreMessage - database inconsistency")
                let result = matches[0].updated_at?.compare(pfObject.updatedAt!)
                if result == ComparisonResult.orderedSame {
                    return matches[0]
                } else {
                    print(matches[0].updated_at!, matches[0].profile_image!)
                    print(pfObject.updatedAt!, pfObject["avatar"]!)
                    configure(coreUser: matches[0], with: pfObject)
                    print(matches[0])
                    return matches[0]
                }
            }
        } catch {
            throw error
        }
        let coreUser = CoreUser(context: context)
        configure(coreUser: coreUser, with: pfObject)
        return coreUser
    }
    
    // create or update coreUser object
    private class func configure(coreUser: CoreUser, with user: PFObject) {
        guard let id = user.objectId, let profileImage = user["avatar"] as? String, let timezone = user["timezone"] as? String, let username = user["username"] as? String, let uuid = user["uuid"] as? String, let bio = user["bio"] as? String else {
            fatalError("findOrCreateCoreUser: - failed to parse PFObject")
        }
        coreUser.id = id as String
        coreUser.bio = bio
        coreUser.profile_image = profileImage
        coreUser.timezone = timezone
        coreUser.username = username
        coreUser.uuid = uuid
        coreUser.created_at = user.createdAt! as NSDate
        coreUser.updated_at = user.updatedAt! as NSDate
    }

}





















