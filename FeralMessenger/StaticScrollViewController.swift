//
//  StaticScrollViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 7/1/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import AudioToolbox


class StaticScrollViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate, KeyboardScrollableDelegate {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var defaultButton: UIButton!
    @IBOutlet weak var returnButton: UIButton!
    
    @IBAction func defaultButton_tapped(_ sender: UIButton) {
        self.application_idTextField.text = ParseServerConfiguration.heroku_app_id
        self.server_urlTextField.text = ParseServerConfiguration.heroku_server_url
        self.master_keyTextField.text = ParseServerConfiguration.heroku_master_key
    }
    
    @IBAction private func returnButton_tapped(_ sender: UIButton) {
        dismissServerView()
    }
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBAction private func saveButton_tapped(_ sender: UIButton) {
        guard let id = application_idTextField.text, let url = server_urlTextField.text, let key = master_keyTextField.text else { return }
        if !id.isEmpty && !url.isEmpty && !key.isEmpty {
            attemptToInitiateParse(appID: id, serverUrl: url, masterKey: key)
        } else {
            alertRespond(errorLabel, with: [application_idTextField, server_urlTextField, master_keyTextField], for: ResponseType.failure, with: "Fields cannot be blank")
        }
    }
    
    func attemptToInitiateParse(appID: String, serverUrl: String, masterKey: String) {
        // override this to implement
    }
    
    private func setupViews() {
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
        saveButton.backgroundColor = UIColor.metallicGold
        // defaultButton
        defaultButton.backgroundColor = UIColor.clear
        // returnButton
        returnButton.backgroundColor = UIColor.clear
    }
    
    // MARK: - Sudo
    
    @IBOutlet weak var warningLabel: UILabel!
    
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
    
    func dismissServerView() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupWarningLabelGesture()
        setupScrollViewGesture()
        setupTextFieldDelegates()
        setupKeyboardManager()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keyboardManager?.setupKeyboardScrollableNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        keyboardManager?.removeKeyboardNotifications()
    }
    
    // MARK: - TextFields + UITextFieldDelegate
    
    @IBOutlet weak var application_idTextField: UITextField!
    @IBOutlet weak var server_urlTextField: UITextField!
    @IBOutlet weak var master_keyTextField: UITextField!
    
    private func setupTextFieldDelegates() {
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
    
    // MARK: - KeyboardManager + KeyboardScrollableDelegate
    
    var keyboardManager: KeyboardManager?
    
    func setupKeyboardManager() {
        keyboardManager = KeyboardManager()
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
    
    // MARK: - UIScrollView + UIScrollViewDelegate
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    private func setupScrollViewGesture() {
        scrollView.delegate = self
        let gesture = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped(recognizer:)))
        scrollView.addGestureRecognizer(gesture)
    }
    
    func scrollViewTapped(recognizer: UIGestureRecognizer) {
        scrollView.endEditing(true)
    }
    
}












