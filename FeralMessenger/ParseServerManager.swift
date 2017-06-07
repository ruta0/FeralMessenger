//
//  ParseServerManager.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/6/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import Parse


class ParseServerManager: NSObject {
    
    static let shared = ParseServerManager()
    
    func attemptToInitializeParse() {
        if isParseInitialized == false {
            Parse.initialize(with: ParseConfiguration.config)
            isParseInitialized = true
        }
    }
    
    func saveDeviceToken(with token: Data, completion: @escaping ((Bool) -> Void)) {
        if let installation = PFInstallation.current() {
            installation.setDeviceTokenFrom(token)
            installation.saveInBackground(block: { (completed: Bool, error: Error?) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    completion(true)
                }
            })
        } else {
            print("current installation is nil")
        }
    }
    
}
