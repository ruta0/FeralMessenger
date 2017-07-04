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
    
    static let createdSortDescriptor = NSSortDescriptor(key: "created_at", ascending: false, selector: #selector(NSString.localizedCompare(_:)))
    
    class func defaultQuery(with predicate: NSPredicate?) -> PFQuery<PFObject>? {        
        // query for users
        let query = PFQuery(className: User.parseClassName(), predicate: predicate)
        let usernameSortDescriptor = NSSortDescriptor(key: "username", ascending: true, selector: #selector(NSString.localizedCompare(_:)))
        query.order(by: [usernameSortDescriptor])
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
        // friends
        let friends = [String]()
        self["friends"] = friends
        // device specific
        self["uuid"] = UIDevice.current.identifierForVendor!.uuidString
        self["sysVersion"] = UIDevice.current.systemVersion
        self["sysName"] = UIDevice.current.systemName
        self["timezone"] = NSTimeZone.system.identifier
        self["model"] = UIDevice.current.model
    }
    
}




























