//
//  User.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/21/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import Parse


// This is a PFUser object to handle temporarily JSON transaction between REST and Core Data. The primary model object for user is CoreUser
final class User: PFUser {
    
//    var id: String
    var profile_image: String
//    var username: String
//    var email: String
//    var pass: String

    var uuid: String
    var sysName: String
    var sysVersion: String
    var timezone: String
    var model: String
    
    func query() -> PFQuery<PFObject>? {
        let query = PFQuery(className: User.parseClassName())
        query.includeKey("User")
        query.order(byAscending: "created_at")
        return query
    }
    
    // username, email and password are inheritated from PFUser
    func constructUserInfo(name: String, email: String, pass: String) {
        // user specific
        self.username = name
        self.email = email
        self.password = pass
        self["avatar"] = "Cat"
        self["bio"] = "...(ツ)..."
        // device specific
        self["uuid"] = UIDevice.current.identifierForVendor!.uuidString
        self["sysVersion"] = UIDevice.current.systemVersion
        self["sysName"] = UIDevice.current.systemName
        self["timezone"] = NSTimeZone.system.identifier
        self["model"] = UIDevice.current.model
    }
    
    override init() {
        profile_image = String()
        uuid = String()
        sysName = String()
        sysVersion = String()
        timezone = String()
        model = String()
        super.init()
    }
    
}




























