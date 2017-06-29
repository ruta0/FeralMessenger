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
import CloudKit


class AuthViewController: AdaptiveScrollViewController {
    
    private enum AuthButtonType: String {
        case login = "Login"
        case signup = "Sign Up"
    }
    
    private enum ToggleButtonType: String {
        case returnToLogin = "Return to Login"
        case createAnAccount = "Create an Account"
    }
    
    var ckManager: CloudKitManager?
    var parseManager: ParseManager?
    
    @IBOutlet weak var dividerViewOne: UIView!
    
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
                // login
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
                // signup
                authButton.isEnabled = false
                beginLoadingAnime()
                parseManager?.createCurrentUser(with: nameTextField.text, email: emailTextField.text, pass: passTextField.text)
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
    private func changeEmailTextFieldAlpha(sender: UITextField) {
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
    
    private func changeAuthButtonTitle(sender: UIButton) {
        DispatchQueue.main.async { 
            if sender.titleLabel?.text == AuthButtonType.login.rawValue {
                sender.setTitle(AuthButtonType.signup.rawValue, for: UIControlState.normal)
            } else {
                sender.setTitle(AuthButtonType.login.rawValue, for: UIControlState.normal)
            }
        }
    }
    
    private func changeToggleButtonTitle(sender: UIButton) {
        DispatchQueue.main.async { 
            if sender.titleLabel?.text == ToggleButtonType.createAnAccount.rawValue {
                sender.setTitle(ToggleButtonType.returnToLogin.rawValue, for: UIControlState.normal)
            } else {
                sender.setTitle(ToggleButtonType.createAnAccount.rawValue, for: UIControlState.normal)
            }
        }
    }
    
    private func setupLogoImageViewGesture() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let hourString = dateFormatter.string(from: date)
        if let hourInt = Int(hourString) {
            if hourInt >= 3 || hourInt < 23 {
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
    
    private let segueToServerConfigViewController = "SegueToServerConfigViewController"
    
    @objc private func presentServerConfigView(gestureRecognizer: UITapGestureRecognizer) {
        if logoImageView.tintColor != UIColor.metallicGold() {
            DispatchQueue.main.async {
                self.logoImageView.tintColor = UIColor.metallicGold()
                self.performSegue(withIdentifier: self.segueToServerConfigViewController, sender: self)
            }
        }
    }
    
    private let segueToTabBarController = "SegueToTabBarController"
    
    fileprivate func presentMasterView() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: self.segueToTabBarController, sender: self)
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
        setupParseManager()
        setupKeyboardScrollableDelegate()
        // login
        KeychainManager.shared.loadAuthToken { (token: String?) in
            if token != nil {
                self.performLogin(token: token!)
            }
        }
    }
    
}


// MARK: - UITextFieldDelegate

extension AuthViewController {
    
    func setupTextFieldDelegates() {
        nameTextField.delegate = self
        emailTextField.delegate = self
        passTextField.delegate = self
    }
    
}


// MARK: - KeyboardScrollableDelegate

extension AuthViewController: KeyboardScrollableDelegate {
    
    func setupKeyboardScrollableDelegate() {
        keyboardManager?.scrollableDelegate = self
    }
    
    func keyboardDidHide(from notification: Notification, in keyboardRect: CGRect) {
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardRect.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }
    
    func keyboardDidShow(from notification: Notification, in keyboardRect: CGRect) {
        self.scrollView.isScrollEnabled = true
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardRect.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        var aRect: CGRect = self.view.frame
        aRect.size.height -= keyboardRect.height
        if let activeField = self.passTextField {
            if (!aRect.contains(activeField.frame.origin)) {
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
}


// MARK: - Parse

extension AuthViewController: ParseUsersManagerDelegate {
    
    func setupParseManager() {
        parseManager = ParseManager()
        parseManager?.userDelegate = self
    }
    
    func didCreateUser(completed: Bool, error: Error?) {
        self.authButton.isEnabled = true
        self.endLoadingAnime()
        self.passTextField.text?.removeAll()
        if error != nil {
            self.alertRespond(self.errorLabel, with: [self.nameTextField, self.emailTextField, self.passTextField], for: ResponseType.failure, with: error!.localizedDescription, completion: {
            })
        } else {
            if completed == true {
                self.alertRespond(self.errorLabel, with: [self.nameTextField, self.emailTextField, self.passTextField], for: ResponseType.success, with: "Success. Please proceed to login", completion: nil)
            }
        }
    }
    
    func performLogin(name: String, pass: String, completion: @escaping (PFUser?) -> Void) {
        guard let name = nameTextField.text?.lowercased(), let pass = passTextField.text else { return }
        parseManager?.attemptToInitializeParse()
        beginLoadingAnime()
        authButton.isEnabled = false
        PFUser.logInWithUsername(inBackground: name, password: pass, block: { [weak self] (pfUser: PFUser?, error: Error?) in
            self?.endLoadingAnime()
            self?.authButton.isEnabled = true
            self?.passTextField.text?.removeAll()
            if error != nil {
                self?.alertRespond((self?.errorLabel)!, with: [(self?.nameTextField)!, (self?.passTextField)!], for: ResponseType.failure, with: error!.localizedDescription, completion: {
                })
            } else {
                completion(pfUser)
            }
        })
    }
    
    func performLogin(token: String) {
        parseManager?.attemptToInitializeParse()
        beginLoadingAnime()
        alertRespond(errorLabel, with: nil, for: ResponseType.normal, with: "Resumming to previous session", completion: nil)
        authButton.isEnabled = false
        PFUser.become(inBackground: token, block: { (pfUser: PFUser?, error: Error?) in
            self.endLoadingAnime()
            self.authButton.isEnabled = true
            self.passTextField.text?.removeAll()
            if error != nil {
                self.alertRespond((self.errorLabel)!, with: [(self.nameTextField)!, (self.passTextField)!], for: ResponseType.failure, with: error!.localizedDescription, completion: {
                })
                KeychainManager.shared.deleteAuthToken(in: KeychainConfiguration.accountType.auth_token.rawValue)
            } else {
                KeychainManager.shared.persistAuthToken(with: token)
                self.presentMasterView()
            }
        })
    }

}


extension AuthViewController: CloudKitManagerDelegate {
    
    func setupCloudKitManager() {
        ckManager = CloudKitManager()
        ckManager?.delegate = self
    }
    
    func ckErrorHandler(error: CKError) {
        print(error)
    }
    
    func didCreateRecord(ckRecord: CKRecord?, error: Error?) {
        //
    }
    
    func didSubscribed(subscription: CKSubscription?, error: Error?) {
        //
    }
    
}













