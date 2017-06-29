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
    
    private func setupViews() {
        // scrollView
        scrollView.isScrollEnabled = false
        scrollView.backgroundColor = UIColor.midNightBlack()
        // contentView
        contentView.backgroundColor = UIColor.clear
    }
    
    // MARK: - KeyboardManager
    
    func setupKeyboardManager() {
        keyboardManager = KeyboardManager()
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupScrollViewGesture()
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

















