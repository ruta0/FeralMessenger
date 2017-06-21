//
//  KeychainManager.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/6/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import Parse
import Locksmith
import CloudKit


class KeychainManager: NSObject {
    
    static let shared = KeychainManager()
    
    // MARK: - Authentication
    
    func persistAuthToken(with token: String) {
        do {
            try Locksmith.updateData(data: [KeychainConfiguration.accountType.auth_token.rawValue : token], forUserAccount: KeychainConfiguration.accountType.auth_token.rawValue, inService: KeychainConfiguration.serviceName)
        } catch let err {
            print(err.localizedDescription)
        }
    }
    
    func persistDeviceToken(with token: Data) {
        // convert the token into string
        let deviceToken = token.map { String(format: "%02.2hhx", $0) }.joined()
        do {
            try Locksmith.updateData(data: [KeychainConfiguration.accountType.device_token.rawValue : deviceToken], forUserAccount: KeychainConfiguration.accountType.device_token.rawValue, inService: KeychainConfiguration.serviceName)
        } catch let err {
            print(err.localizedDescription)
        }
    }
    
    func loadAuthToken(completion: @escaping ((_ token: String?) -> Void)) {
        if let dictionary = Locksmith.loadDataForUserAccount(userAccount: KeychainConfiguration.accountType.auth_token.rawValue, inService: KeychainConfiguration.serviceName) {
            let token = dictionary[KeychainConfiguration.accountType.auth_token.rawValue] as? String
            completion(token)
        } else {
            print("No keychain service found, do nothing")
        }
    }
    
    func deleteAuthToken(in userAccount: String) {
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: userAccount, inService: KeychainConfiguration.serviceName)
        } catch let err {
            print(err.localizedDescription)
        }
    }
    
    // MARK: - CloudKit Subscription
    
    func persistCKSubscription(subscription: CKSubscription) {
        do {
            try Locksmith.updateData(data: [CloudKitSubscription.SubscriptionKey : subscription], forUserAccount: KeychainConfiguration.accountType.ck_subscription.rawValue, inService: KeychainConfiguration.serviceName)
        } catch let err {
            print("persistCKSubscription: - ", err.localizedDescription)
        }
    }
    
}































