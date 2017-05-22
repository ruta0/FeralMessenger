//
//  User.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/21/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import Foundation
import Parse


final class User: PFUser {
    
    @NSManaged var name: String
    @NSManaged var profile_image: String?
    @NSManaged var messages: [Message]?
    
    init(name: String, profile_image: String?, messages: [Message]?) {
        super.init()
        self.name = name
        self.profile_image = profile_image
        self.messages = messages
    }
    
    override init() {
        super.init()
    }
    
}




























