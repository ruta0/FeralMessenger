//
//  ServerConfigViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/23/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import Parse
import AudioToolbox


class ServerConfigViewController: AdaptiveScrollViewController {
    
    // MARK: - UI
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var application_idTextField: UITextField!
    @IBOutlet weak var server_urlTextField: UITextField!
    @IBOutlet weak var master_keyTextField: UITextField!
    @IBOutlet weak var defaultButton: UIButton!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var returnButton: UIButton!
    
    @IBAction func defaultButton_tapped(_ sender: UIButton) {
        self.application_idTextField.text = ParseServerConfiguration.heroku_app_id
        self.server_urlTextField.text = ParseServerConfiguration.heroku_server_url
        self.master_keyTextField.text = ParseServerConfiguration.heroku_master_key
    }
    
    fileprivate func setupViews() {
        // warningLabel
        warningLabel.isUserInteractionEnabled = true
        // errorLabel
        errorLabel.alpha = 0.0
        // application_idTextField
        application_idTextField.borderStyle = UITextBorderStyle.none
        application_idTextField.attributedPlaceholder = NSAttributedString(string: "application_id", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        // server_urlTextField
        server_urlTextField.borderStyle = UITextBorderStyle.none
        server_urlTextField.attributedPlaceholder = NSAttributedString(string: "https://server_url/parse", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        // master_keyTextField
        master_keyTextField.borderStyle = UITextBorderStyle.none
        master_keyTextField.attributedPlaceholder = NSAttributedString(string: "master_key", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        // saveButton
        saveButton.layer.cornerRadius = 25 // height is set to 50 in storyboard
        saveButton.backgroundColor = UIColor.metallicGold()
        // defaultButton
        defaultButton.backgroundColor = UIColor.clear
        // returnButton
        returnButton.backgroundColor = UIColor.clear
    }
    
    private func setupWarningLabelGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(enableSudo(gestureRecognizer:)))
        gesture.numberOfTapsRequired = 49
        warningLabel.addGestureRecognizer(gesture)
    }
    
    @objc private func enableSudo(gestureRecognizer: UITapGestureRecognizer) {
        alertRespond(errorLabel, with: nil, for: ResponseType.success, with: "sudo granted", completion: {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            isSudoGranted = true
            DispatchQueue.main.async {
                self.warningLabel.textColor = UIColor.green
            }
        })
    }
    
    // MARK: - Lifecycle
    
    @IBAction func returnButton_tapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupWarningLabelGesture()
        setupTextFieldDelegates()
        setupKeyboardScrollableDelegate()
    }
    
    // MARK: - Parse
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBAction func saveButton_tapped(_ sender: UIButton) {
        if application_idTextField.text != "" && server_urlTextField.text != "" && master_keyTextField.text != "" {
            attemptToInitiateParse(appId: application_idTextField.text!, serverUrl: server_urlTextField.text!, masterKey: master_keyTextField.text!)
        } else {
            alertRespond(errorLabel, with: [application_idTextField, server_urlTextField, master_keyTextField], for: ResponseType.failure, with: "Fields cannot be blank", completion: {
                self.master_keyTextField.text?.removeAll()
            })
        }
    }
    
    fileprivate func attemptToInitiateParse(appId: String, serverUrl: String, masterKey: String) {
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


// MARK: - UITextFieldDelegate

extension ServerConfigViewController {
    
    fileprivate func setupTextFieldDelegates() {
        application_idTextField.delegate = self
        server_urlTextField.delegate = self
        master_keyTextField.delegate = self
    }
    
}


// MARK: - KeyboardScrollableDelegate

extension ServerConfigViewController: KeyboardScrollableDelegate {
    
    func setupKeyboardScrollableDelegate() {
        keyboardManager?.scrollableDelegate = self
    }
    
    func keyboardDidShow(from notification: Notification, in keyboardRect: CGRect) {
        self.scrollView.isScrollEnabled = true
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardRect.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardRect.height
        if let activeField = self.master_keyTextField {
            if (!aRect.contains(activeField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    func keyboardDidHide(from notification: Notification, in keyboardRect: CGRect) {
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardRect.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }
    
}




















