//
//  KeyboardManager.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/13/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit


// MARK: - KeyboardDockableDelegate

protocol KeyboardDockableDelegate {
    func keyboardDidChangeFrame(from notification: Notification, in keyboardRect: CGRect)
}


// MARK: - KeyboardScrollableDelegate

protocol KeyboardScrollableDelegate {
    func keyboardDidShow(from notification: Notification, in keyboardRect: CGRect)
    func keyboardDidHide(from notification: Notification, in keyboardRect: CGRect)
}


/// - To use KeyboardDockableDelegate, first initiate KeyboardManager and then setup the add and remove observers. Then answer to the delegate methods.
class KeyboardManager: NSObject {
    
    // MARK: - Class wide implementation
    
    func removeKeyboardNotifications() {
        if #available(iOS 9, *) {
            // ignore
        } else {
            NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
        }
    }
    
    private func getKeyboardFrame(notification: Notification) -> CGRect? {
        let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        return keyboardRect
    }
    
    // MARK: - KeyboardDockableDelegate
    
    var dockableDelegate: KeyboardDockableDelegate?
    
    func handleKeyboardDockable(notification: Notification) {
        if let keyboardRect = getKeyboardFrame(notification: notification) {
            dockableDelegate?.keyboardDidChangeFrame(from: notification, in: keyboardRect)
        }
    }
    
    func setupKeyboardDockableNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDockable(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDockable(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // MARK: - KeyboardScrollableDelegate
    
    var scrollableDelegate: KeyboardScrollableDelegate?
    
    func keyboardScrollableWillShow(notification: Notification) {
        if let keyboardRect = getKeyboardFrame(notification: notification) {
            scrollableDelegate?.keyboardDidShow(from: notification, in: keyboardRect)
        }
    }
    
    func keyboardScrollableWillHide(notification: Notification) {
        if let keyboardRect = getKeyboardFrame(notification: notification) {
            scrollableDelegate?.keyboardDidHide(from: notification, in: keyboardRect)
        }
    }
    
    func setupKeyboardScrollableNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardScrollableWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardScrollableWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
}


























