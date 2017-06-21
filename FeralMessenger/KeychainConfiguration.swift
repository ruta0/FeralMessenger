//
//  KeychainConfiguration.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/6/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import Foundation


struct KeychainConfiguration {
    
    static let serviceName = "feral"
    static let accessGroup = "feral"
    
    enum accountType: String {
        case auth_token = "auth_token"
        case device_token = "device_token"
        case email = "email"
        case password = "pass"
        case ck_subscription = "ck_subscription"
    }
    
}
