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


class ServerConfigViewController: UIViewController {
    
    enum ResponseType {
        case normal
        case success
        case failure
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var application_idTextField: UITextField!
    @IBOutlet weak var server_urlTextField: UITextField!
    @IBOutlet weak var master_keyTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var defaultButton: UIButton!
    @IBOutlet weak var returnButton: UIButton!
    
    @IBAction func saveButton_tapped(_ sender: UIButton) {
        if application_idTextField.text != "" && server_urlTextField.text != "" && master_keyTextField.text != "" {
            attemptToInitiateParse(appId: application_idTextField.text!, serverUrl: server_urlTextField.text!, masterKey: master_keyTextField.text!)
        } else {
            handleResponse(type: ServerConfigViewController.ResponseType.failure, message: "Fields cannot be blank")
        }
    }
    
    @IBAction func defaultButton_tapped(_ sender: UIButton) {
        self.application_idTextField.text = ParseConfig.heroku_app_id
        self.server_urlTextField.text = ParseConfig.heroku_server_url
        self.master_keyTextField.text = ParseConfig.heroku_master_key
    }
    
    @IBAction func returnButton_tapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func toggleScrollViewScrolling(notification: Notification) {
        let isKeyboardShowing = (notification.name == NSNotification.Name.UIKeyboardWillShow)
        if isKeyboardShowing == true {
            scrollView.isScrollEnabled = true
        } else {
            scrollView.setContentOffset(CGPoint(x: self.scrollView.contentOffset.x, y: 0), animated: true)
            scrollView.isScrollEnabled = false
        }
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.toggleScrollViewScrolling), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.toggleScrollViewScrolling), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private func setupViews() {
        // scrollView
        scrollView.isScrollEnabled = false
        scrollView.backgroundColor = UIColor.midNightBlack()
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupKeyboardNotifications()
        setupTextFieldDelegates()
        setupScrollViewDelegate()
        setupScrollViewGesture()
    }
    
}


extension ServerConfigViewController: UITextFieldDelegate {
    
    func setupTextFieldDelegates() {
        application_idTextField.delegate = self
        server_urlTextField.delegate = self
        master_keyTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}


// MARK: - UIScrollViewDelegate

extension ServerConfigViewController: UIScrollViewDelegate {
    
    func setupScrollViewDelegate() {
        scrollView.delegate = self
    }
    
    func setupScrollViewGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped(recognizer:)))
        scrollView.addGestureRecognizer(gesture)
    }
    
    func scrollViewTapped(recognizer: UIGestureRecognizer) {
        scrollView.endEditing(true)
    }
    
}





















