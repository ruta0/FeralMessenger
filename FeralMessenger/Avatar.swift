//
//  Avatar.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/3/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import Foundation


// Avatar is not model associated with the Avatars.plist
final class Avatar {
    
    var name: String
    
    init(nameDictionary: Dictionary<String, String>) {
        self.name = nameDictionary["avatar"]!
    }
    
}
