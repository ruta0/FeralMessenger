//
//  UIViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/20/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit


extension UIViewController {
    
    /// on completion, this method returns the auth_token as String or an Error
    func fetchTokenFromKeychain(accountName: String, completion: @escaping (_ token: String) -> ()) {
        do {
            let tokenItem = KeychainItem(service: KeychainConfiguration.serviceName, account: accountName, accessGroup: KeychainConfiguration.accessGroup)
            let token = try tokenItem.readPassword()
            completion(token)
        } catch let err {
            // when token doesn't exist under this accountName
            // optional: perform logout or renew token
            print("Error fetching token from Keychain - \(err)")
        }
    }
    
}
