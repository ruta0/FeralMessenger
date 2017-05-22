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
    
    private func persistUserData(pfUser: PFUser?, completion: () -> ()) {
        guard let user = pfUser, let auth_token = user.sessionToken else { return }
        storeSecretInKeychain(secret: auth_token, account: "auth_token") // this method almost always don't fail
        completion()
    }
    
    func performLogin(name: String, pass: String) {
        guard let name = nameTextField.text?.lowercased(), let pass = passTextField.text else { return }
        if Reachability.isConnectedToNetwork() == true {
            self.activityIndicator.startAnimating()
            // I am using email as username
            PFUser.logInWithUsername(inBackground: name, password: pass, block: { (pfUser: PFUser?, error: Error?) in
                self.activityIndicator.stopAnimating()
                self.passTextField.text = ""
                if error != nil {
                    self.handleResponse(type: AuthViewController.ResponseType.failure, message: error!.localizedDescription)
                } else {
                    self.persistUserData(pfUser: pfUser, completion: {
                        self.performSegue(withIdentifier: "HomeViewControllerSegue", sender: self)
                    })
                }
            })
        } else {
            handleResponse(type: AuthViewController.ResponseType.failure, message: "Failed to connect to Internet")
        }
    }
    
    func performSignup(name: String, email: String, pass: String) {
        guard let name = nameTextField.text?.lowercased(), let email = emailTextField.text?.lowercased(), let pass = passTextField.text else { return }
        if Reachability.isConnectedToNetwork() == true {
            self.activityIndicator.startAnimating()
            let newUser = PFUser()
            newUser.username = name
            newUser.email = email
            newUser.password = pass
            newUser.signUpInBackground(block: { (completed: Bool, error: Error?) in
                self.activityIndicator.stopAnimating()
                self.passTextField.text = ""
                if error != nil {
                    self.handleResponse(type: AuthViewController.ResponseType.failure, message: error!.localizedDescription)
                } else {
                    self.handleResponse(type: AuthViewController.ResponseType.success, message: "Success! Please proceed to login.")
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
        } else if type == ResponseType.failure {
            errorLabel.textColor = UIColor.red
            errorLabel.flash(delay: 4, message: message)
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            nameTextField.jitter(repeatCount: 5)
            emailTextField.jitter(repeatCount: 5)
            passTextField.jitter(repeatCount: 5)
            passTextField.text = ""
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeViewControllerSegue" {
            print(123)
        }
    }
    
}































