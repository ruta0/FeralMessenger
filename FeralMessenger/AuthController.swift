//
//  AuthController.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/21/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import AudioToolbox


extension AuthViewController {
    
    func performLogin(email: String, pass: String) {
        guard let email = emailTextField.text?.lowercased(), let pass = passTextField.text else { return }
        if Reachability.isConnectedToNetwork() == true {
            passTextField.text = ""
            print(email, pass)
        } else {
            handleErrorResponse(message: "Failed to connect to Internet")
        }
    }
    
    func performSignup(name: String, email: String, pass: String) {
        guard let name = nameTextField.text?.lowercased(), let email = emailTextField.text?.lowercased(), let pass = passTextField.text else { return }
        if Reachability.isConnectedToNetwork() == true {
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
    
}
