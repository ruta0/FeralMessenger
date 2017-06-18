//
//  AuthViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/21/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import Parse
import AudioToolbox
import Locksmith


class AuthViewController: UIViewController {
    
    // MARK: UIScrollView
    
    fileprivate enum AuthButtonType: String {
        case login = "Login"
        case signup = "Sign Up"
    }
    
    fileprivate enum ToggleButtonType: String {
        case returnToLogin = "Return to Login"
        case createAnAccount = "Create an Account"
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var buttonStackView: UIStackView!
    
    @IBOutlet weak var dividerViewOne: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var toggleButton: UIButton!
    
    @IBAction func authButton_tapped(_ sender: UIButton) {
        if sender.titleLabel?.text == AuthButtonType.login.rawValue {
            if nameTextField.text != "" && passTextField.text != "" {
                performLogin(name: nameTextField.text!, pass: passTextField.text!, completion: { (pfUser: PFUser?) in
                    if pfUser != nil {
                        KeychainManager.shared.persistAuthToken(with: (pfUser?.sessionToken!)!)
                        self.presentMasterView()
                    }
                })
            } else {
                alertRespond(errorLabel, with: [emailTextField, passTextField], for: ResponseType.failure, with: "Fields cannot be blank", completion: {
                    self.passTextField.text?.removeAll()
                })
            }
        } else {
            if nameTextField.text != "" && emailTextField.text != "" && passTextField.text != "" {
                createUserInParse(with: nameTextField.text!, email: emailTextField.text!.lowercased(), pass: passTextField.text!)
            } else {
                alertRespond(errorLabel, with: [nameTextField, emailTextField, passTextField], for: ResponseType.failure, with: "Fields cannot be blank", completion: { 
                    self.passTextField.text?.removeAll()
                })
            }
        }
    }
    
    @IBAction func toggleButton_tapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.changeEmailTextFieldAlpha(sender: self.emailTextField)
            self.changeAuthButtonTitle(sender: self.authButton)
            self.changeToggleButtonTitle(sender: self.toggleButton)
        }, completion: nil)
    }
    
    // I should've use stackView to do this instead.
    fileprivate func changeEmailTextFieldAlpha(sender: UITextField) {
        DispatchQueue.main.async { 
            if sender.alpha == 0.0 {
                // show
                self.dividerViewOne.alpha = 1.0
                sender.alpha = 1.0
            } else {
                // hide
                sender.alpha = 0.0
                self.dividerViewOne.alpha = 0.0
            }
        }
    }
    
    fileprivate func changeAuthButtonTitle(sender: UIButton) {
        DispatchQueue.main.async { 
            if sender.titleLabel?.text == AuthButtonType.login.rawValue {
                sender.setTitle(AuthButtonType.signup.rawValue, for: UIControlState.normal)
            } else {
                sender.setTitle(AuthButtonType.login.rawValue, for: UIControlState.normal)
            }
        }
    }
    
    fileprivate func changeToggleButtonTitle(sender: UIButton) {
        DispatchQueue.main.async { 
            if sender.titleLabel?.text == ToggleButtonType.createAnAccount.rawValue {
                sender.setTitle(ToggleButtonType.returnToLogin.rawValue, for: UIControlState.normal)
            } else {
                sender.setTitle(ToggleButtonType.createAnAccount.rawValue, for: UIControlState.normal)
            }
        }
    }
    
    fileprivate func setupLogoImageViewGesture() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let hourString = dateFormatter.string(from: date)
        if let hourInt = Int(hourString) {
            if hourInt >= 23 || hourInt < 3 {
                let gesture = UITapGestureRecognizer(target: self, action: #selector(presentServerConfigView(gestureRecognizer:)))
                gesture.numberOfTapsRequired = 7
                logoImageView.addGestureRecognizer(gesture)
            } else {
                print("time is still too early :(")
            }
        }
    }
    
    private func setupViews() {
        // scrollView
        scrollView.isScrollEnabled = false
        scrollView.backgroundColor = UIColor.midNightBlack()
        // logoImageView
        let originalImage = UIImage(named: "AppLogo")
        let tinitedImage = originalImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        logoImageView.image = tinitedImage
        logoImageView.tintColor = UIColor.white
        if UIScreen.main.bounds.size == CGSize(width: 414, height: 736) {
            logoImageView.frame.size.height = 64
        }
        // errorLabel
        errorLabel.alpha = 0.0
        // nameTF
        nameTextField.borderStyle = UITextBorderStyle.none
        nameTextField.attributedPlaceholder = NSAttributedString(string: "name", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        // dividerViewOne
        dividerViewOne.alpha = 0.0
        // emailTF
        emailTextField.alpha = 0.0
        emailTextField.borderStyle = UITextBorderStyle.none
        emailTextField.attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        // passTF
        passTextField.borderStyle = UITextBorderStyle.none
        passTextField.attributedPlaceholder = NSAttributedString(string: "pass", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        // authButton
        authButton.layer.cornerRadius = 25 // height is set to 50 in storyboard
        authButton.backgroundColor = UIColor.mandarinOrange()
        authButton.setTitle(AuthButtonType.login.rawValue, for: UIControlState.normal)
        // termsButton
        termsButton.backgroundColor = UIColor.clear
        // toggleButton
        toggleButton.backgroundColor = UIColor.clear
        toggleButton.setTitle(ToggleButtonType.createAnAccount.rawValue, for: UIControlState.normal)
    }
    
    // MARK: - Lifecycle
    
    private let termsUrl: String = "https://sheltered-ridge-89457.herokuapp.com/terms"
    
    @IBAction func termsButton_tapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "You will be redirected to your browser for the following URL", message: "\(termsUrl)", preferredStyle: UIAlertControllerStyle.alert)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        let redirect = UIAlertAction(title: "Redirect", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            self.redirectToBrowserForTerms()
        }
        alert.addAction(cancel)
        alert.addAction(redirect)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc private func presentServerConfigView(gestureRecognizer: UITapGestureRecognizer) {
        if logoImageView.tintColor != UIColor.metallicGold() {
            DispatchQueue.main.async {
                self.logoImageView.tintColor = UIColor.metallicGold()
                self.performSegue(withIdentifier: "ServerConfigViewControllerSegue", sender: self)
            }
        }
    }
    
    fileprivate func presentMasterView() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "ChatsViewControllerSegue", sender: self)
        }
    }
    
    private func redirectToBrowserForTerms() {
        guard let termsUrl = URL(string: termsUrl) else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(termsUrl, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(termsUrl)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLogoImageViewGesture()
        setupTextFieldDelegates()
        setupScrollViewDelegate()
        setupScrollViewGesture()
        KeychainManager.shared.loadAuthToken { (token: String?) in
            if token != nil {
                self.performLogin(token: token!)
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        registerForKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        deregisterFromKeyboardNotifications()
    }
    
}


// MARK: - UITextFieldDelegate + Keyboard

extension AuthViewController: UITextFieldDelegate {
    
    func setupTextFieldDelegates() {
        nameTextField.delegate = self
        emailTextField.delegate = self
        passTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deregisterFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification){
        // Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect: CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.passTextField {
            if (!aRect.contains(activeField.frame.origin)) {
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        // Once keyboard disappears, restore original positions
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

extension AuthViewController: UIScrollViewDelegate {
    
    fileprivate func setupScrollViewDelegate() {
        scrollView.delegate = self
    }
    
    fileprivate func setupScrollViewGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped(recognizer:)))
        scrollView.addGestureRecognizer(gesture)
    }
    
    func scrollViewTapped(recognizer: UIGestureRecognizer) {
        scrollView.endEditing(true)
    }
    
}


// MARK: - Parse

extension AuthViewController {
    
    func performLogin(name: String, pass: String, completion: @escaping (PFUser?) -> Void) {
        guard let name = nameTextField.text?.lowercased(), let pass = passTextField.text else { return }
        ParseServerManager.shared.attemptToInitializeParse()
        self.activityIndicator.startAnimating()
        authButton.isEnabled = false
        PFUser.logInWithUsername(inBackground: name, password: pass, block: { [weak self] (pfUser: PFUser?, error: Error?) in
            self?.activityIndicator.stopAnimating()
            self?.authButton.isEnabled = true
            self?.passTextField.text = ""
            if error != nil {
                self?.alertRespond((self?.errorLabel)!, with: [(self?.nameTextField)!, (self?.passTextField)!], for: ResponseType.failure, with: error!.localizedDescription, completion: {
                    self?.passTextField.text?.removeAll()
                })
            } else {
                completion(pfUser)
            }
        })
    }
    
    func performLogin(token: String) {
        ParseServerManager.shared.attemptToInitializeParse()
        self.activityIndicator.startAnimating()
        alertRespond(errorLabel, with: nil, for: ResponseType.normal, with: "Resumming to previous session", completion: nil)
        authButton.isEnabled = false
        PFUser.become(inBackground: token, block: { [weak self] (pfUser: PFUser?, error: Error?) in
            self?.activityIndicator.stopAnimating()
            self?.authButton.isEnabled = true
            if error != nil {
                self?.alertRespond((self?.errorLabel)!, with: [(self?.nameTextField)!, (self?.passTextField)!], for: ResponseType.failure, with: error!.localizedDescription, completion: {
                    self?.passTextField.text?.removeAll()
                })
                KeychainManager.shared.deleteAuthToken(in: KeychainConfiguration.accountType.auth_token.rawValue)
            } else {
                KeychainManager.shared.persistAuthToken(with: token)
                self?.presentMasterView()
            }
        })
    }
    
    func createUserInParse(with name: String, email: String, pass: String) {
        guard let name = nameTextField.text?.lowercased(), let email = emailTextField.text?.lowercased(), let pass = passTextField.text else { return }
        ParseServerManager.shared.attemptToInitializeParse()
        self.activityIndicator.startAnimating()
        authButton.isEnabled = false
        let newUser = User()
        newUser.constructUserInfo(name: name, email: email, pass: pass)
        newUser.signUpInBackground(block: { [unowned self] (completed: Bool, error: Error?) in
            self.authButton.isEnabled = true
            self.activityIndicator.stopAnimating()
            self.passTextField.text = ""
            if error != nil {
                self.alertRespond(self.errorLabel, with: [self.nameTextField, self.emailTextField, self.passTextField], for: ResponseType.failure, with: error!.localizedDescription, completion: {
                    self.passTextField.text?.removeAll()
                })
            } else {
                if completed == true {
                    self.alertRespond(self.errorLabel, with: [self.nameTextField, self.emailTextField, self.passTextField], for: ResponseType.success, with: "Success. Please proceed to login", completion: nil)
                }
            }
        })
    }
    
}













