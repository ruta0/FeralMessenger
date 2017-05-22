//
//  ParseServerConfigs.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/20/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import Foundation
import Parse


public class ParseConfig {
    
    // MARK: - mLab db configs
    
    static var dbUserId: String = "heroku_swxl1fjq.heroku_swxl1fjq"
    static var dbUser: String = "heroku_swxl1fjq"
    static var dbPass: String = ""
    static let dbURL: String = "mongodb://\(dbUser):\(dbPass)@ds149511.mlab.com:49511/heroku_swxl1fjq"
    
    // MARK: - server configs
    
    static var heroku_app_name = "feralmesgrightmeow"
    static var heroku_app_id = "feralmesgrightmeow_pMPQEwj64C"
    static var heroku_master_key = "feralmesgrightmeow_Kifk4HA7uH"
    static var heroku_server_url = "https://feralmesgrightmeow.herokuapp.com/parse"
    
    static let config = ParseClientConfiguration {
        $0.applicationId = heroku_app_id
        $0.server = heroku_server_url
        $0.clientKey = heroku_master_key
    }
    
}
