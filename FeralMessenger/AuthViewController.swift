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
import CoreData


class AuthViewController: UIViewController {
    
    fileprivate enum AuthButtonType: String {
        case login = "Login"
        case signup = "Sign Up"
    }
    
    fileprivate enum ToggleButtonType: String {
        case returnToLogin = "Return to Login"
        case createAnAccount = "Create an Account"
    }
    
    let termsUrl: String = "https://sheltered-ridge-89457.herokuapp.com/terms"
    
    var accountName: String?
    
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
                performLogin(name: nameTextField.text!, pass: passTextField.text!)
            } else {
                localTextResponder(errorLabel, for: ResponseType.failure, with: "Fields cannot be blank", completion: { [weak self] in
                    self?.jitterAndReset()
                })
            }
        } else {
            if nameTextField.text != "" && emailTextField.text != "" && passTextField.text != "" {
                createUserInParse(with: nameTextField.text!, email: emailTextField.text!.lowercased(), pass: passTextField.text!)
            } else {
                localTextResponder(errorLabel, for: ResponseType.failure, with: "Fields cannot be blank", completion: { [weak self] in
                    self?.jitterAndReset()
                })
            }
        }
    }
    
    @IBAction func termsButton_tapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "You will be redirected to your browser for the following URL", message: "\(termsUrl)", preferredStyle: UIAlertControllerStyle.alert)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil)
        let redirect = UIAlertAction(title: "Redirect", style: UIAlertActionStyle.destructive) { (action: UIAlertAction) in
            self.redirectToBrowserForTerms()
        }
        alert.addAction(cancel)
        alert.addAction(redirect)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func toggleButton_tapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.changeEmailTextFieldAlpha(sender: self.emailTextField)
            self.changeAuthButtonTitle(sender: self.authButton)
            self.changeToggleButtonTitle(sender: self.toggleButton)
        }, completion: nil)
    }
    
    fileprivate func jitterAndReset() {
        nameTextField.jitter(repeatCount: 5)
        emailTextField.jitter(repeatCount: 5)
        passTextField.jitter(repeatCount: 5)
        passTextField.text = ""
    }
    
    // I should've use stackView to do this instead.
    fileprivate func changeEmailTextFieldAlpha(sender: UITextField) {
        if sender.alpha == 0.0 {
            dividerViewOne.alpha = 1.0
            sender.alpha = 1.0
        } else {
            sender.alpha = 0.0
            dividerViewOne.alpha = 0.0
        }
    }
    
    fileprivate func changeAuthButtonTitle(sender: UIButton) {
        if sender.titleLabel?.text == AuthButtonType.login.rawValue {
            sender.setTitle(AuthButtonType.signup.rawValue, for: UIControlState.normal)
        } else {
            sender.setTitle(AuthButtonType.login.rawValue, for: UIControlState.normal)
        }
    }
    
    fileprivate func changeToggleButtonTitle(sender: UIButton) {
        if sender.titleLabel?.text == ToggleButtonType.createAnAccount.rawValue {
            sender.setTitle(ToggleButtonType.returnToLogin.rawValue, for: UIControlState.normal)
        } else {
            sender.setTitle(ToggleButtonType.createAnAccount.rawValue, for: UIControlState.normal)
        }
    }
    
    fileprivate func setupLogoImageViewGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(presentServerConfigView(gestureRecognizer:)))
        gesture.numberOfTapsRequired = 7
        logoImageView.addGestureRecognizer(gesture)
    }
    
    fileprivate func setupViews() {
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
    
}


// MARK: - Lifecycle

extension AuthViewController {
    
    internal func presentServerConfigView(gestureRecognizer: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "ServerConfigViewControllerSegue", sender: self)
    }
    
    fileprivate func presentHomeView() {
        self.performSegue(withIdentifier: "HomeViewControllerSegue", sender: self)
    }
    
    fileprivate func redirectToBrowserForTerms() {
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
        checkUserLoginSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(true)
        registerForKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        deregisterFromKeyboardNotifications()
    }
    
}


// MARK: - UITextFieldDelegate

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
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if let activeField = self.passTextField {
            if (!aRect.contains(activeField.frame.origin)){
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


// MARK: - Keychain

extension AuthViewController {
    
    func checkUserLoginSession() {
        fetchTokenFromKeychain(accountName: "auth_token") { (token: String) in
            self.readUserInParse(with: token)
        }
    }
    
    fileprivate func storeSecretInKeychain(secret: String, account: String) {
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
    
    fileprivate func removeSecretInKeychain(account: String) {
        print(account)
    }
    
}


// MARK: - Core Data

extension AuthViewController {
    
    fileprivate func createOrUpdateUserDataInKeychain(with pfUser: PFUser?, completion: () -> ()) {
        guard let user = pfUser, let auth_token = user.sessionToken else { return }
        storeSecretInKeychain(secret: auth_token, account: "auth_token")
        completion()
    }
    
}


// MARK: - Parse

extension AuthViewController {
    
    func performLogin(name: String, pass: String) {
        guard let name = nameTextField.text?.lowercased(), let pass = passTextField.text else { return }
        if Reachability.isConnectedToNetwork() == true {
            ParseConfig.attemptToInitializeParse()
            self.activityIndicator.startAnimating()
            PFUser.logInWithUsername(inBackground: name, password: pass, block: { [weak self] (pfUser: PFUser?, error: Error?) in
                self?.activityIndicator.stopAnimating()
                self?.passTextField.text = ""
                if error != nil {
                    self?.localTextResponder((self?.errorLabel)!, for: ResponseType.failure, with: error!.localizedDescription, completion: nil)
                } else {
                    self?.createOrUpdateUserDataInKeychain(with: pfUser, completion: {
                        self?.presentHomeView()
                    })
                }
            })
        } else {
            localTextResponder(errorLabel, for: ResponseType.failure, with: "Failed to connect to Internet", completion: { [weak self] in
                self?.jitterAndReset()
            })
        }
    }
    
    func readUserInParse(with token: String) {
        if Reachability.isConnectedToNetwork() == true {
            ParseConfig.attemptToInitializeParse()
            self.activityIndicator.startAnimating()
            localTextResponder(errorLabel, for: ResponseType.normal, with: "Resumming to previous session", completion: nil)
            UIApplication.shared.beginIgnoringInteractionEvents()
            PFUser.become(inBackground: token, block: { [weak self] (pfUser: PFUser?, error: Error?) in
                self?.activityIndicator.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                if error != nil {
                    self?.localTextResponder((self?.errorLabel)!, for: ResponseType.failure, with: error!.localizedDescription, completion: { [weak self] in
                        self?.jitterAndReset()
                    })
                    self?.removeSecretInKeychain(account: "auth_token")
                } else {
                    self?.storeSecretInKeychain(secret: token, account: "auth_token")
                    self?.presentHomeView()
                }
            })
        } else {
            localTextResponder(errorLabel, for: ResponseType.failure, with: "Failed to connect to Internet", completion: { [weak self] in
                self?.jitterAndReset()
            })
        }
    }
    
    func createUserInParse(with name: String, email: String, pass: String) {
        guard let name = nameTextField.text?.lowercased(), let email = emailTextField.text?.lowercased(), let pass = passTextField.text else { return }
        if Reachability.isConnectedToNetwork() == true {
            ParseConfig.attemptToInitializeParse()
            self.activityIndicator.startAnimating()
            let newUser = User()
            newUser.constructUserInfo(name: name, email: email, pass: pass)
            newUser.signUpInBackground(block: { [weak self] (completed: Bool, error: Error?) in
                self?.activityIndicator.stopAnimating()
                self?.passTextField.text = ""
                if error != nil {
                    self?.localTextResponder((self?.errorLabel)!, for: ResponseType.failure, with: error!.localizedDescription, completion: { [weak self] in
                        self?.jitterAndReset()
                    })
                } else {
                    if completed == true {
                        self?.localTextResponder((self?.errorLabel)!, for: ResponseType.success, with: "Success! Please proceed to login", completion: nil)
                    }
                }
            })
        } else {
            localTextResponder(errorLabel, for: ResponseType.failure, with: "Failed to connect to Internet", completion: { [weak self] in
                self?.jitterAndReset()
            })
        }
    }
    
}













