//
//  CoreMessage.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/27/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import CoreData
import Parse


class CoreMessage: NSManagedObject {
    
    static let entityName = String(describing: CoreMessage.self)
    static let createdSortDescriptor = NSSortDescriptor(key: "created_at", ascending: true)
    
    /// A compound predicate and a descriptor are both provided by default. This is being set across the whole app
    class func defaultFetchRequest(from senderID: String, to receiverID: String) -> NSFetchRequest<CoreMessage> {
        let request: NSFetchRequest<CoreMessage> = CoreMessage.fetchRequest()
        request.fetchLimit = 300
        request.sortDescriptors = [createdSortDescriptor]
        // settting up a compound predicate
        let predicate = NSPredicate(format: "receiverID == %@ AND senderID == %@", receiverID, senderID)
        let inversePredicate = NSPredicate(format: "receiverID == %@ AND senderID == %@", senderID, receiverID)
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate, inversePredicate])
        request.predicate = compoundPredicate
        return request
    }
    
    /// [NOTE]
    /// Even though the following algorithm is written to handle situation where editing is possible. In my opinion, when a message is created and sent, it should be set in stone for good, just like speaking to another person in the real world. I understand that some chat apps would provide user the flexibility of editing a sent message. But that's probably not what I could agree with, for now.
    class func findOrCreateCoreMessage(matching pfObject: PFObject, in context: NSManagedObjectContext) throws -> CoreMessage? {
        let request: NSFetchRequest<CoreMessage> = CoreMessage.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", pfObject.objectId!)
        do {
            let matches = try context.fetch(request) // returning as [CoreMessage]
            if matches.count > 0 {
                assert(matches.count == 1, "CoreMessage.findOrCreateCoreMessage - database inconsistency")
                let result = matches[0].updated_at?.compare(pfObject.updatedAt!)
                if result == ComparisonResult.orderedSame {
                    return matches[0]
                } else {
                    configure(coreMessage: matches[0], with: pfObject)
                    return matches[0]
                }
            }
        } catch {
            throw error
        }
        let coreMessage = CoreMessage(context: context)
        configure(coreMessage: coreMessage, with: pfObject)
        return coreMessage
    }
    
    // create or update coreMessage object
    private class func configure(coreMessage: CoreMessage, with message: PFObject) {
        guard let id = message.objectId,let senderID = message["senderID"] as? String, let receiverID = message["receiverID"] as? String, let created_at = message.createdAt, let updated_at = message.updatedAt else {
            fatalError("findOrCreateCoreMessage: - failed to parse PFObject")
        }
        if let image_path = message["image_path"] as? String {
            coreMessage.image_path = image_path
        }
        if let sms = message["sms"] as? String {
            coreMessage.sms = sms
        }
        coreMessage.id = id
        coreMessage.senderID = senderID
        coreMessage.receiverID = receiverID
        coreMessage.created_at = created_at as NSDate
        coreMessage.updated_at = updated_at as NSDate
        coreMessage.isRead = true
    }

}












