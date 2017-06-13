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


// MARK: - UI

class ServerConfigViewController: UIViewController {
        
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var application_idTextField: UITextField!
    @IBOutlet weak var server_urlTextField: UITextField!
    @IBOutlet weak var master_keyTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var defaultButton: UIButton!
    @IBOutlet weak var returnButton: UIButton!
    @IBOutlet weak var warningLabel: UILabel!
    
    @IBAction func saveButton_tapped(_ sender: UIButton) {
        if application_idTextField.text != "" && server_urlTextField.text != "" && master_keyTextField.text != "" {
            attemptToInitiateParse(appId: application_idTextField.text!, serverUrl: server_urlTextField.text!, masterKey: master_keyTextField.text!)
        } else {
            alertRespond(errorLabel, with: [application_idTextField, server_urlTextField, master_keyTextField], for: ResponseType.failure, with: "Fields cannot be blank", completion: { 
                self.master_keyTextField.text?.removeAll()
            })
        }
    }
    
    @IBAction func defaultButton_tapped(_ sender: UIButton) {
        self.application_idTextField.text = ParseConfiguration.heroku_app_id
        self.server_urlTextField.text = ParseConfiguration.heroku_server_url
        self.master_keyTextField.text = ParseConfiguration.heroku_master_key
    }
    
    @IBAction func returnButton_tapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func setupWarningLabelGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(enableSudo(gestureRecognizer:)))
        gesture.numberOfTapsRequired = 49
        warningLabel.addGestureRecognizer(gesture)
    }
    
    fileprivate func setupViews() {
        // scrollView
        scrollView.isScrollEnabled = false
        scrollView.backgroundColor = UIColor.midNightBlack()
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
    
}


// MARK: - Lifecycle

extension ServerConfigViewController {
    
    internal func enableSudo(gestureRecognizer: UITapGestureRecognizer) {
        alertRespond(errorLabel, with: nil, for: ResponseType.success, with: "sudo granted", completion: {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            isSudoGranted = true
            DispatchQueue.main.async {
                self.warningLabel.textColor = UIColor.green
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupWarningLabelGesture()
        setupTextFieldDelegates()
        setupScrollViewDelegate()
        setupScrollViewGesture()
        registerForKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        deregisterFromKeyboardNotifications()
    }
    
}


// MARK: - UITextFieldDelegate + UIKeyboard

extension ServerConfigViewController: UITextFieldDelegate {
    
    fileprivate func setupTextFieldDelegates() {
        application_idTextField.delegate = self
        server_urlTextField.delegate = self
        master_keyTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    fileprivate func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    fileprivate func deregisterFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    internal func keyboardWasShown(notification: NSNotification) {
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.master_keyTextField {
            if (!aRect.contains(activeField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    internal func keyboardWillBeHidden(notification: NSNotification) {
        //Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }
    
}


// MARK: - UIScrollViewDelegate

extension ServerConfigViewController: UIScrollViewDelegate {
    
    fileprivate func setupScrollViewDelegate() {
        scrollView.delegate = self
    }
    
    fileprivate func setupScrollViewGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped(recognizer:)))
        scrollView.addGestureRecognizer(gesture)
    }
    
    internal func scrollViewTapped(recognizer: UIGestureRecognizer) {
        scrollView.endEditing(true)
    }
    
}


// MARK: - Parse

extension ServerConfigViewController {
    
    fileprivate func attemptToInitiateParse(appId: String, serverUrl: String, masterKey: String) {
        if isParseInitialized == true {
            alertRespond(errorLabel, with: nil, for: ResponseType.normal, with: "Restart the app to setup a new server configuration", completion: nil)
        } else {
            if Reachability.isConnectedToNetwork() == true {
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
            } else {
                alertRespond(errorLabel, with: [application_idTextField, server_urlTextField, master_keyTextField], for: ResponseType.failure, with: "Failed to connect to the Internet", completion: nil)

            }
        }
    }
    
}


















