//
//  StaticScrollViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/3/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit


class AdaptiveScrollViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate, KeyboardScrollableDelegate {
    
    private enum AuthButtonType: String {
        case login = "Login"
        case signup = "Sign Up"
    }
    
    private enum ToggleButtonType: String {
        case returnToLogin = "Return to Login"
        case createAnAccount = "Create an Account"
    }
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var dividerViewOne: UIView!
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var toggleButton: UIButton!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    func beginLoadingAnime() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
    }
    
    func endLoadingAnime() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }
    
    func performLogin(name: String, pass: String) {
        // override this to implement manual login with user and pass
    }
    
    func performLogin() {
        // override this to implement auto login with token
    }
    
    func performSignup(name: String, email: String, pass: String) {
        // override this to implement
    }
    
    @IBAction private func authButton_tapped(_ sender: UIButton) {
        if sender.currentTitle == AuthButtonType.login.rawValue {
            guard let name = nameTextField.text, let pass = passTextField.text else { return }
            if !name.isEmpty && !pass.isEmpty {
                performLogin(name: name, pass: pass)
            } else {
                alertRespond(errorLabel, with: [nameTextField, passTextField], for: ResponseType.failure, with: "Fields cannot be blank", completion: {
                })
            }
        } else {
            guard let name = nameTextField.text, let email = emailTextField.text, let pass = passTextField.text else { return }
            if !name.isEmpty && !email.isEmpty && !pass.isEmpty {
                performSignup(name: name, email: email, pass: pass)
            } else {
                alertRespond(errorLabel, with: [nameTextField, emailTextField, passTextField], for: ResponseType.failure, with: "Fields cannot be blank", completion: {
                })
            }
        }
    }
    
    @IBAction private func termsButton_tapped(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: "Redirect to Terms?", preferredStyle: UIAlertControllerStyle.alert)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        let action = UIAlertAction(title: "Redirect", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            self.redirectToTerms()
        }
        alert.addAction(cancel)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func toggleButton_tapped(_ sender: UIButton) {
        if sender.currentTitle == ToggleButtonType.createAnAccount.rawValue {
            UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { 
                sender.setTitle(ToggleButtonType.returnToLogin.rawValue, for: UIControlState.normal)
                self.emailTextField.alpha = 1
                self.dividerViewOne.alpha = 1
                self.authButton.setTitle(AuthButtonType.signup.rawValue, for: UIControlState.normal)
            }, completion: nil)
        } else if sender.currentTitle == ToggleButtonType.returnToLogin.rawValue {
            UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { 
                sender.setTitle(ToggleButtonType.createAnAccount.rawValue, for: UIControlState.normal)
                self.emailTextField.alpha = 0
                self.dividerViewOne.alpha = 0
                self.authButton.setTitle(AuthButtonType.login.rawValue, for: UIControlState.normal)
            }, completion: nil)
        }
    }
    
    private func setupViews() {
        let foreGroundMagnitude: Float = 20
        let backgroundMagnitude: Float = -15
        // scrollView
        scrollView.isScrollEnabled = false
        scrollView.backgroundColor = UIColor.midNightBlack
        // contentView
        contentView.backgroundColor = UIColor.clear
        // backgroundImage
        backgroundImageView.enableParallaxMotion(magnitude: backgroundMagnitude)
        // errorLabel
        errorLabel.alpha = 0
        // logoImageView
        let originalImage = UIImage(named: "AppLogo")
        let tinitedImage = originalImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        logoImageView.image = tinitedImage
        logoImageView.tintColor = UIColor.white
        if UIScreen.main.bounds.size == CGSize(width: 414, height: 736) {
            logoImageView.frame.size.height = 64
        }
        logoImageView.enableParallaxMotion(magnitude: foreGroundMagnitude)
        // nameTF
        nameTextField.borderStyle = UITextBorderStyle.none
        nameTextField.attributedPlaceholder = NSAttributedString(string: "name", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        nameTextField.enableParallaxMotion(magnitude: foreGroundMagnitude)
        // dividerViewOne
        dividerViewOne.alpha = 0
        // emailTF
        emailTextField.alpha = 0
        emailTextField.enableParallaxMotion(magnitude: foreGroundMagnitude)
        emailTextField.borderStyle = UITextBorderStyle.none
        emailTextField.attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        // passTF
        passTextField.borderStyle = UITextBorderStyle.none
        passTextField.attributedPlaceholder = NSAttributedString(string: "pass", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        passTextField.enableParallaxMotion(magnitude: foreGroundMagnitude)
        // authButton
        authButton.layer.cornerRadius = 25 // height is set to 50 in storyboard
        authButton.backgroundColor = UIColor.mandarinOrange
        authButton.setTitle(AuthButtonType.login.rawValue, for: UIControlState.normal)
        authButton.enableParallaxMotion(magnitude: foreGroundMagnitude)
        // termsButton
        termsButton.backgroundColor = UIColor.clear
        termsButton.enableParallaxMotion(magnitude: foreGroundMagnitude)
        // toggleButton
        toggleButton.backgroundColor = UIColor.clear
        toggleButton.enableParallaxMotion(magnitude: foreGroundMagnitude)
        toggleButton.setTitle(ToggleButtonType.createAnAccount.rawValue, for: UIControlState.normal)
    }
    
    // MARK: - LogoImageView
    
    @IBOutlet weak var logoImageView: UIImageView!
    
    /// need to refactor this method later
    private func isLogoImageViewEnabled() -> Bool {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        let hourString = dateFormatter.string(from: date)
        if let hourInt = Int(hourString) {
            if hourInt >= 3 || hourInt < 23 {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    private func setupLogoImageViewGesture() {
        if isLogoImageViewEnabled() == true {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(presentServerConfigView(gestureRecognizer:)))
            gesture.numberOfTapsRequired = 7
            logoImageView.addGestureRecognizer(gesture)
        }
    }
    
    // MARK: - Lifecycle
    
    func redirectToTerms() {
        // override this to implement
    }
    
    func presentServerConfigView(gestureRecognizer: UITapGestureRecognizer) {
        // override this to implement
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupLogoImageViewGesture()
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
    
    // MARK: - KeyboardManager + KeyboardScrollableDelegate
    
    var keyboardManager: KeyboardManager?
    
    func setupKeyboardManager() {
        keyboardManager = KeyboardManager()
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
    
    // MARK: - TextFields + UITextFieldDelegate
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    
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








