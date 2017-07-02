//
//  ServerConfigViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/23/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import Parse


class ServerConfigViewController: StaticScrollViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Parse
    
    override func attemptToInitiateParse(appID: String, serverUrl: String, masterKey: String) {
        if isParseInitialized == true {
            alertRespond(errorLabel, with: nil, for: ResponseType.normal, with: "Restart the app to setup a new server configuration", completion: nil)
        } else {
            guard let url: URL = URL(string: serverUrl) else { return }
            if UIApplication.shared.canOpenURL(url) == true {
                ParseServerManager.shared.attemptToInitializeParse()
                alertRespond(errorLabel, with: nil, for: ResponseType.success, with: "Server initialized with provided credentials", completion: {
                    self.master_keyTextField.text?.removeAll()
                    self.server_urlTextField.text?.removeAll()
                })
            } else {
                alertRespond(errorLabel, with: [application_idTextField, server_urlTextField, master_keyTextField], for: ResponseType.failure, with: "Invalid URL", completion: {
                    self.server_urlTextField.text?.removeAll()
                })
            }
        }
    }
    
}























