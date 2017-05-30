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
    
    class func findOrCreateCoreMessage(matching message: PFObject, in context: NSManagedObjectContext) throws -> CoreMessage? {
        let request: NSFetchRequest<CoreMessage> = CoreMessage.fetchRequest()
        request.predicate = NSPredicate(format: "id = %@", message.objectId!)
        
        do {
            let matches = try context.fetch(request) // returning as [Message]
            if matches.count > 0 {
                assert(matches.count == 1, "CoreMessage.findOrCreateCoreMessage - database inconsistency")
                return matches[0]
            }
        } catch {
            throw error
        }
        
        let coreMessage = CoreMessage(context: context)
        coreMessage.id = message.objectId!
//        coreMessage.created_at = message["created_at"] as? NSDate
//        coreMessage.updated_at = message["updated_at"] as? NSDate
        coreMessage.sms = message["sms"]! as? String // this could be nil
        coreMessage.sender_name = message["senderName"]! as? String
        coreMessage.receiver_name = message["receiverName"]! as? String
        return coreMessage
    }

}












