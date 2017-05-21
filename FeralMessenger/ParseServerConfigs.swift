//
//  ParseServerConfigs.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/20/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import Foundation

public class ParseServerConfig {
    
    // MARK: - mLab db configs
    
    static var dbUser: String = "heroku_dg3m3mnx"
    static var dbPass: String = ""
    static let dbURL: String = "mongodb://\(dbUser):\(dbPass)@ds149221.mlab.com:49221/heroku_dg3m3mnx"
    
}
