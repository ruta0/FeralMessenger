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
    @NSManaged var image: PFFile?
    @NSManaged var senderId: String
    @NSManaged var receiverId: String
    @NSManaged var sms: String?
    
    init(image: PFFile?, senderId: String, receiverId: String, sms: String?) {
        super.init()
        self.image = image
        self.senderId = senderId
        self.receiverId = receiverId
        self.sms = sms
    }
    
    override init() {
        super.init()
    }
    
    override class func query() -> PFQuery<PFObject>? {
        let query = PFQuery(className: Message.parseClassName())
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
