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
    
    class func findOrCreateCoreMessage(matching pfObject: PFObject, in context: NSManagedObjectContext) throws -> CoreMessage? {
        let request: NSFetchRequest<CoreMessage> = CoreMessage.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", pfObject.objectId!)
        do {
            let matches = try context.fetch(request) // returning as [CoreMessage]
            if matches.count > 0 {
                assert(matches.count == 1, "CoreMessage.findOrCreateCoreMessage - database inconsistency")
                return matches[0]
            }
        } catch {
            throw error
        }
        let coreMessage = CoreMessage(context: context)
        guard let id = pfObject.objectId, let sender_name = pfObject["senderName"] as? String, let receiver_name = pfObject["receiverName"] as? String, let sms = pfObject["sms"] as? String, let created_at = pfObject.createdAt, let updated_at = pfObject.updatedAt else {
            fatalError("findOrCreateCoreMessage: - failed to parse PFObject")
        }
        coreMessage.id = id
        coreMessage.created_at = created_at as NSDate
        coreMessage.updated_at = updated_at as NSDate
        coreMessage.sms = sms
        coreMessage.sender_name = sender_name
        coreMessage.receiver_name = receiver_name        
        return coreMessage
    }

}












