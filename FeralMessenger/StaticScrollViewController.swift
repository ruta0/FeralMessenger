//
//  StaticScrollViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/3/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import AudioToolbox


public protocol StaticScrollViewControllerDelegate : class, UIScrollViewDelegate {
    
    var lastTextField: UITextField? { get set } // the last item could be a UITextField, else be nil
    var lastTextView: UITextView? { get set } // the last item could be a UITextView, else be nil
    
}

extension StaticScrollViewControllerDelegate {
    
    @available(iOS 10.0, *)
    func registerLastTextFieldOnView(_ lastTextField: UITextField) { }
    
    @available(iOS 10.0, *)
    func registerLastTextViewOnView(_ lastTextView: UITextView) { }
    
}

/**
 StaticScrollViewController conforms to StaticScrollViewControllerDelegate.
 Either lastTextField or lastTextView can be instantiated but not at the same time.
 */
@available(iOS 6.0, *)
open class StaticScrollViewController: UIViewController, UIScrollViewDelegate, StaticScrollViewControllerDelegate {
    
    public var lastTextView: UITextView?

    public var lastTextField: UITextField?
    
    open var scrollView: UIScrollView!
    
    func scrollViewTapped(recognizer: UIGestureRecognizer) {
        scrollView.endEditing(true)
    }
    
    func keyboardWasShown(notification: NSNotification) {
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        
        // Depending on whether it is a UITextField or UITextView, it scrolls to the visible last UIView...thing
        if let activeField = self.lastTextField {
            if (!aRect.contains(activeField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        } else if let activeField = self.lastTextView {
            if (!aRect.contains(activeField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        } else {
            fatalError("Both lastTextField and lastTextView are nil")
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        //Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }
    
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deregisterFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func setupScrollViewGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped(recognizer:)))
        scrollView.addGestureRecognizer(gesture)
    }
    
    func setupScrollViewDelegate() {
        scrollView.delegate = self
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollViewDelegate()
    }
    
}


// MARK: - UITextFieldDelegate

extension StaticScrollViewController: UITextFieldDelegate {
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
}


// MARK: - UITextViewDelegate

extension StaticScrollViewController: UITextViewDelegate {
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    
}


// MARK: - CompletionCorrespondence

extension StaticScrollViewController {
    
    // The handler will display a dynamic message while the responder will perform animation, vibration, sounds, etc.
    // In case of success, responderTextFields will be cleared; in case of failure, responderTextFields will be cleared and perform jitter while in UIColor.red; in case or normal, it depends...
    func completionWithResponder(_ handler: UILabel, with responders: [UITextField]?, for type: ResponseType, with message: String, completion: (() -> Void)? = nil) {
        print("localTextResponder - type \(type): \(message)")
        switch type {
        case .success:
            handler.flash(delay: 5, duration: 0.3, message: message, color: UIColor.green)
            if let responders = responders {
                for responder in responders {
                    responder.text = ""
                }
            }
        case .failure:
            handler.flash(delay: 5, duration: 0.3, message: message, color: UIColor.red)
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            if let responders = responders {
                for responder in responders {
                    responder.text = ""
                    responder.jitter(repeatCount: 5)
                }
            }
        case .normal:
            handler.flash(delay: 7, duration: 0.3, message: message, color: UIColor.orange)
        }
        completion?()
    }
    
}



























