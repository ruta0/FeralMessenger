//
//  AuthController.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/21/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import AudioToolbox
import Parse


extension AuthViewController {
    
    func checkUserLoginSession() {
        fetchTokenFromKeychain(accountName: "auth_token") { (token: String) in
            self.performLogin(token: token)
        }
    }
    
    // synchronize call is on the not being handled correctly - fix this
    func performLogin(token: String) {
        if Reachability.isConnectedToNetwork() == true {
            ParseConfig.attemptToInitializeParse()
            self.activityIndicator.startAnimating()
            handleResponse(type: AuthViewController.ResponseType.normal, message: "Resumming to previous session")
            UIApplication.shared.beginIgnoringInteractionEvents()
            PFUser.become(inBackground: token, block: { (pfUser: PFUser?, error: Error?) in
                self.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.storeSecretInKeychain(secret: token, account: "auth_token")
                self.presentHomeView()
            })
        } else {
            handleResponse(type: AuthViewController.ResponseType.failure, message: "Failed to connect to Internet")
        }
    }
    
    func performLogin(name: String, pass: String) {
        guard let name = nameTextField.text?.lowercased(), let pass = passTextField.text else { return }
        if Reachability.isConnectedToNetwork() == true {
            ParseConfig.attemptToInitializeParse()
            self.activityIndicator.startAnimating()
            // I am using email as username
            PFUser.logInWithUsername(inBackground: name, password: pass, block: { (pfUser: PFUser?, error: Error?) in
                self.activityIndicator.stopAnimating()
                self.passTextField.text = ""
                if error != nil {
                    self.handleResponse(type: AuthViewController.ResponseType.failure, message: error!.localizedDescription)
                } else {
                    self.persistUserData(pfUser: pfUser, completion: {
                        self.presentHomeView()
                    })
                }
            })
        } else {
            handleResponse(type: AuthViewController.ResponseType.failure, message: "Failed to connect to Internet")
        }
    }
    
    // Very tricky to handle. PFUser is not persistent to the device and it cannot be subclass like CoreData mode objects...Unless I use another subclass an Managed object and call it something like DeviceUser or Owner or something else...
    func performSignup(name: String, email: String, pass: String) {
        guard let name = nameTextField.text?.lowercased(), let email = emailTextField.text?.lowercased(), let pass = passTextField.text else { return }
        if Reachability.isConnectedToNetwork() == true {
            ParseConfig.attemptToInitializeParse()
            self.activityIndicator.startAnimating()
            let newUser = User()
            newUser.constructUserInfo(name: name, email: email, pass: pass)
            newUser.signUpInBackground(block: { (completed: Bool, error: Error?) in
                self.activityIndicator.stopAnimating()
                self.passTextField.text = ""
                if error != nil {
                    self.handleResponse(type: AuthViewController.ResponseType.failure, message: error!.localizedDescription)
                } else {
                    self.handleResponse(type: AuthViewController.ResponseType.success, message: "Success! Please proceed to login")
                }
            })
        } else {
            handleResponse(type: AuthViewController.ResponseType.failure, message: "Failed to connect to Internet")
        }
    }
    
    func handleResponse(type: ResponseType, message: String) {
        if type == ResponseType.success {
            errorLabel.textColor = UIColor.green
            errorLabel.flash(delay: 5, message: message)
        } else if type == ResponseType.normal {
            errorLabel.textColor = UIColor.orange
            errorLabel.flash(delay: 5, message: message)
        } else if type == ResponseType.failure {
            errorLabel.textColor = UIColor.red
            errorLabel.flash(delay: 5, message: message)
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            nameTextField.jitter(repeatCount: 5)
            emailTextField.jitter(repeatCount: 5)
            passTextField.jitter(repeatCount: 5)
            passTextField.text = ""
        }
    }
    
    func presentHomeView() {
        self.performSegue(withIdentifier: "HomeViewControllerSegue", sender: self)
    }
    
    func redirectToBrowserForTerms() {
        guard let termsUrl = URL(string: termsUrl) else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(termsUrl, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(termsUrl)
        }
    }
    
    // optional: I want to refactor this method into the /keychain/UIViewController extension, the AuthViewController shouldn't be handling this.
    private func storeSecretInKeychain(secret: String, account: String) {
        do {
            self.accountName = account
            if let originalAccountName = self.accountName {
                var passwordItem = KeychainItem(service: KeychainConfiguration.serviceName, account: originalAccountName, accessGroup: KeychainConfiguration.accessGroup)
                try passwordItem.renameAccount(account)
                try passwordItem.savePassword(secret)
            } else {
                // if this is a new account, create a new keychain item
                let tokenItem = KeychainItem(service: KeychainConfiguration.serviceName, account: account, accessGroup: KeychainConfiguration.accessGroup)
                try tokenItem.savePassword(secret)
            }
        } catch {
            fatalError("Error updating keychain = \(error)")
        }
    }
    
    private func persistUserData(pfUser: PFUser?, completion: () -> ()) {
        guard let user = pfUser, let auth_token = user.sessionToken else { return }
        storeSecretInKeychain(secret: auth_token, account: "auth_token")
        completion()
    }
    
}































