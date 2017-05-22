//
//  User.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/21/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import Parse
import UIKit


final class User: PFUser {
    
    @NSManaged var profile_image: String
    @NSManaged var uuid: String
    @NSManaged var sysName: String
    @NSManaged var sysVersion: String
    @NSManaged var timezone: String
    @NSManaged var model: String
    
    func query() -> PFQuery<PFObject>? {
        let query = PFQuery(className: User.parseClassName())
        query.includeKey("User")
        query.order(byAscending: "created_at")
        return query
    }
    
    func constructUserInfo(name: String, email: String, pass: String) {
        self.username = name
        self.email = email
        self.password = pass
        self.uuid = UIDevice.current.identifierForVendor!.uuidString
        self.sysVersion = UIDevice.current.systemVersion
        self.sysName = UIDevice.current.systemName
        self.timezone = NSTimeZone.system.identifier
        self.model = UIDevice.current.model
    }
    
    override init() {
        super.init()
    }
    
}




























