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
    @NSManaged var sender: PFUser
    @NSManaged var receiver: PFUser
    @NSManaged var sms: String?
    
    init(image: PFFile?, sender: PFUser, receiver: PFUser, sms: String?) {
        super.init()
        self.image = image
        self.sender = sender
        self.receiver = receiver
        self.sms = sms
    }
    
    override init() {
        super.init()
    }
    
    override class func query() -> PFQuery<PFObject>? {
        let query = PFQuery(className: Message.parseClassName())
        query.includeKey("user")
        query.order(byDescending: "createdAt")
        return query
    }
    
}


// MARK: - PFSubclassing

extension Message: PFSubclassing {
    
    static func parseClassName() -> String {
        return "Message"
    }
    
}
