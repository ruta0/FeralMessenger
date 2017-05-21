//
//  AuthViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/21/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit


class AuthViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var infoStackView: UIStackView!
    @IBOutlet weak var buttonStackView: UIStackView!
    
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
        // implement this
        passTextField.text = ""
    }
    
    @IBAction func termsButton_tapped(_ sender: UIButton) {
        print(123)
    }
    
    @IBAction func toggleButton_tapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.25, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.changeUsernameTextFieldAlpha(sender: self.nameTextField)
            self.changeAuthButtonTitle(sender: self.authButton)
            self.changeToggleButtonTitle(sender: self.toggleButton)
        }, completion: nil)
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
    
    // I should've use stackView to do this instead.
    private func changeUsernameTextFieldAlpha(sender: UITextField) {
        if sender.alpha == 0.0 {
            dividerViewOne.alpha = 1.0
            sender.alpha = 1.0
        } else {
            sender.alpha = 0.0
            dividerViewOne.alpha = 0.0
        }
    }
    
    private func changeAuthButtonTitle(sender: UIButton) {
        if sender.titleLabel?.text == "Login" {
            sender.setTitle("Sign Up", for: UIControlState.normal)
        } else {
            sender.setTitle("Login", for: UIControlState.normal)
        }
    }
    
    private func changeToggleButtonTitle(sender: UIButton) {
        if sender.titleLabel?.text == "Create an Account" {
            sender.setTitle("Return to Login", for: UIControlState.normal)
        } else {
            sender.setTitle("Create an Account", for: UIControlState.normal)
        }
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.toggleScrollViewScrolling), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.toggleScrollViewScrolling), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private func setupViews() {
        // scrollView
        scrollView.isScrollEnabled = false
        // logoImageView
        let originalImage = UIImage(named: "AppLogo")
        let tinitedImage = originalImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        logoImageView.image = tinitedImage
        logoImageView.tintColor = UIColor.white
        // errorLabel
        errorLabel.isHidden = true
        // nameTF
        nameTextField.borderStyle = UITextBorderStyle.none
        nameTextField.attributedPlaceholder = NSAttributedString(string: "name", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        // emailTF
        emailTextField.borderStyle = UITextBorderStyle.none
        emailTextField.attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        // passTF
        passTextField.borderStyle = UITextBorderStyle.none
        passTextField.attributedPlaceholder = NSAttributedString(string: "pass", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        // authButton
        authButton.layer.cornerRadius = 20 // height is set to 40 in storyboard
        authButton.backgroundColor = UIColor.mandarinOrange()
        authButton.setTitle("Login", for: UIControlState.normal)
        // termsButton
        termsButton.backgroundColor = UIColor.clear
        // toggleButton
        toggleButton.backgroundColor = UIColor.clear
        toggleButton.setTitle("Create an Account", for: UIControlState.normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupKeyboardNotifications()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // implement this
    }
    
}



























