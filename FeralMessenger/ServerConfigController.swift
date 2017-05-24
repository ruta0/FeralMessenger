//
//  ServerConfigController.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/23/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import Foundation
import AudioToolbox
import Parse


extension ServerConfigViewController {
    
    func attemptToInitiateParse(appId: String, serverUrl: String, masterKey: String) {
        if isParseInitialized == true {
            handleResponse(type: ServerConfigViewController.ResponseType.normal, message: "Restart the app to setup a new server configuration")
        } else {
            if Reachability.isConnectedToNetwork() == true {
                guard let url: URL = URL(string: serverUrl) else { return }
                if UIApplication.shared.canOpenURL(url) == true {
                    ParseConfig.heroku_app_id = appId
                    ParseConfig.heroku_server_url = serverUrl
                    ParseConfig.heroku_master_key = masterKey
                    ParseConfig.attemptToInitializeParse()
                    handleResponse(type: ServerConfigViewController.ResponseType.success, message: "Server initialized with provided credentials")
                    master_keyTextField.text = ""
                } else {
                    handleResponse(type: ServerConfigViewController.ResponseType.failure, message: "Invalid URL")
                }
            } else {
                handleResponse(type: ServerConfigViewController.ResponseType.failure, message: "Failed to connect to Internet")
            }
        }
    }
    
    func handleResponse(type: ResponseType, message: String) {
        if type == ResponseType.success {
            errorLabel.textColor = UIColor.green
            errorLabel.flash(delay: 5, message: message)
        } else if type == ResponseType.normal {
            errorLabel.textColor = UIColor.orange
            errorLabel.flash(delay: 7, message: message)
            master_keyTextField.text = ""
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        } else if type == ResponseType.failure {
            errorLabel.textColor = UIColor.red
            errorLabel.flash(delay: 5, message: message)
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            application_idTextField.jitter(repeatCount: 5)
            server_urlTextField.jitter(repeatCount: 5)
            master_keyTextField.jitter(repeatCount: 5)
            master_keyTextField.text = ""
        }
    }
    
    func initializeParseWithNewConfigs() {
        
    }
    
}
