//
//  Message.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/21/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import Parse


class Message: PFObject {
    
    // parse handles the id, created_at, updated_at automatically
    var image_path: String?
    var senderID: String?
    var receiverID: String?
    var sms: String?
    var isRead: Bool?
    
    override init() {
        super.init()
    }
    
    // not fetching with the correct predicates???
    class func query(receiverID: String, senderID: String) -> PFQuery<PFObject>? {
        // query for message
        let predicate = NSPredicate(format: "receiverID == %@ AND senderID == %@", receiverID, senderID)
        let inversePredicate = NSPredicate(format: "receiverID == %@ AND senderID == %@", senderID, receiverID)
        let compoundedPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate, inversePredicate])
        let query = PFQuery(className: Message.parseClassName(), predicate: compoundedPredicate)
        query.order(byDescending: "created_at")
        return query
    }
    
    func constructMessageInfo(sms: String, receiverID: String, senderID: String) {
        self["sms"] = sms
        self["isRead"] = false
        // self["image_path"] = image_path
        self["receiverID"] = receiverID
        self["senderID"] = senderID
    }
    
}


// MARK: - PFSubclassing

extension Message: PFSubclassing {
    
    static func parseClassName() -> String {
        return "Message"
    }
    
}

























