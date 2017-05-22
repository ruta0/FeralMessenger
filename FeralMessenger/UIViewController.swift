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
            let tokenItem = KeychainItem(service: KeychainConfiguration.serviceName, account: KeychainConfiguration.accountName, accessGroup: KeychainConfiguration.accessGroup)
            let token = try tokenItem.readPassword()
            completion(token)
        } catch let err {
            // when token doesn't exist under this accountName
            // optional: perform logout or renew token
            fatalError("Error fetching token from Keychain - \(err)")
        }
    }
    
    // optional: complete this automated login method with calls to fetch token from keychain. Remember to handle errors when token expires
    func autoLogin(token: String) {
        print(123)
    }
    
}
