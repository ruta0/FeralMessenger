//
//  KeyboardManager.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/13/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit


protocol KeyboardDockable {
    func keyboardDidMove()
}


class InputContainerView: UIView {
    
    var delegate: KeyboardDockable?
    
    var containerHeight: CGFloat?
    
    private func getKeyboardFrameSize(notification: Notification) -> CGRect? {
        if let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            return keyboardRect
        } else {
            return nil
        }
    }
    
    func handleKeyboardNotification(notification: Notification) {
        if let keyboardRect = getKeyboardFrameSize(notification: notification) {
            let keyboardWillShow = (notification.name == NSNotification.Name.UIKeyboardWillShow)
            containerHeight = keyboardWillShow ? (containerHeight! + keyboardRect.height) : containerHeight
            delegate?.keyboardDidMove()
        }
    }
    
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupKeyboardNotifications()
        containerHeight = self.frame.size.height
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeKeyboardNotifications()
    }
    
}



































