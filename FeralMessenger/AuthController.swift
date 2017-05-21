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
    
    func performLogin(email: String, pass: String) {
        guard let email = emailTextField.text?.lowercased(), let pass = passTextField.text else { return }
        if Reachability.isConnectedToNetwork() == true {
            self.activityIndicator.startAnimating()
            passTextField.text = ""
            PFUser.logInWithUsername(inBackground: email, password: pass, block: { (pfUser: PFUser?, error: Error?) in
                self.activityIndicator.stopAnimating()
                if error != nil {
                    self.handleErrorResponse(message: error!.localizedDescription)
                } else {
                    // success
                    self.performSegue(withIdentifier: "HomeViewControllerSegue", sender: self)
                }
            })
        } else {
            handleErrorResponse(message: "Failed to connect to Internet")
        }
    }
    
    func performSignup(name: String, email: String, pass: String) {
        guard let name = nameTextField.text?.lowercased(), let email = emailTextField.text?.lowercased(), let pass = passTextField.text else { return }
        if Reachability.isConnectedToNetwork() == true {
            self.activityIndicator.startAnimating()
            passTextField.text = ""
            print(name, email, pass)
        } else {
            handleErrorResponse(message: "Failed to connect to Internet")
        }
    }
    
    func handleErrorResponse(message: String) {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        nameTextField.jitter(repeatCount: 5)
        emailTextField.jitter(repeatCount: 5)
        passTextField.jitter(repeatCount: 5)
        passTextField.text = ""
        errorLabel.flash(delay: 4, message: message)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "HomeViewControllerSegue" {
            print(123)
        }
    }
    
}































