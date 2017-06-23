//
//  StaticScrollViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/3/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit


class AdaptiveScrollViewController: UIViewController {
    
    // MARK: - UI & API
    
    var keyboardManager: KeyboardManager?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var bottomTextField: UITextField!
    
    func beginLoadingAnime() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
    }
    
    func stopLoadingAnime() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
        }
    }
    
    private func setupViews() {
        // scrollView
        scrollView.isScrollEnabled = false
        scrollView.backgroundColor = UIColor.midNightBlack()
        // contentView
        contentView.backgroundColor = UIColor.clear
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
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
    
}


// MARK: - KeyboardScrollableDelegate

extension AdaptiveScrollViewController: KeyboardScrollableDelegate {
    
    fileprivate func setupKeyboardManager() {
        keyboardManager = KeyboardManager()
        keyboardManager?.scrollableDelegate = self
    }
    
    func keyboardDidHide(from notification: Notification, in keyboardRect: CGRect) {
        self.scrollView.isScrollEnabled = true
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardRect.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardRect.height
        if let activeField = self.bottomTextField {
            if (!aRect.contains(activeField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    func keyboardDidShow(from notification: Notification, in keyboardRect: CGRect) {
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardRect.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }
    
}


// MARK: - UITextFieldDelegate

extension AdaptiveScrollViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
}


// MARK: - UIScrollViewDelegate

extension AdaptiveScrollViewController: UIScrollViewDelegate {
    
    fileprivate func setupScrollViewGesture() {
        scrollView.delegate = self
        let gesture = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped(recognizer:)))
        scrollView.addGestureRecognizer(gesture)
    }
    
    func scrollViewTapped(recognizer: UIGestureRecognizer) {
        scrollView.endEditing(true)
    }
    
}

















