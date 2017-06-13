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
    func registerLastTextFieldOnView(_ lastTextField: UITextField) { }
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
    
    func keyboardWillHide(notification: NSNotification) {
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
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


























