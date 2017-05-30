//
//  Message.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/21/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import Foundation
import Parse


final class Message: PFObject {
    
    // parse handles the id, created_at, updated_at automatically
    var image: PFFile?
    var senderName: String
    var receiverName: String
    var sms: String?
    
    init(image: PFFile?, senderName: String, receiverName: String, sms: String?) {
        self.image = image
        self.senderName = senderName
        self.receiverName = receiverName
        self.sms = sms
        super.init()
    }
    
    override init() {
        senderName = String()
        receiverName = String()
        super.init()
    }
    
    // not fetching with the correct predicates???
    class func query(receiverName: String, senderName: String) -> PFQuery<PFObject>? {
        let predicate = NSPredicate(format: "receiverName == %@ AND senderName == %@", receiverName, senderName)
        let inversePredicate = NSPredicate(format: "receiverName == %@ AND senderName == %@", senderName, receiverName)
        let compoundedPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate, inversePredicate])
        let query = PFQuery(className: Message.parseClassName(), predicate: compoundedPredicate)
        query.includeKey("Message")
        query.order(byDescending: "created_at")
        return query
    }
    
}


// MARK: - PFSubclassing

extension Message: PFSubclassing {
    
    static func parseClassName() -> String {
        return "Message"
    }
    
}

























