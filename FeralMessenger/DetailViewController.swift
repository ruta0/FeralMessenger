//
//  DetailViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/20/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import Parse
import CoreData


// MARK: - UI

class DetailViewController: FetchedResultsCollectionViewController {
    
    var bottomConstraint: NSLayoutConstraint?
    var selectedUserName: String?
    
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.mediumBlueGray()
        return view
    }()
    
    let topBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = UIColor.white
        textField.backgroundColor = UIColor.clear
        textField.attributedPlaceholder = NSAttributedString(string: "Enter message...", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        textField.keyboardAppearance = UIKeyboardAppearance.dark
        return textField
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("Send", for: UIControlState.normal)
        button.backgroundColor = UIColor.clear
        let titleColor = UIColor.white
        button.setTitleColor(titleColor, for: UIControlState.normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(sendMessage), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    func sendMessage() { }
    
    func reloadCollectionView() {
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
            self.scrollToLastCellItem()
        }
    }
    
    func scrollToLastCellItem() {
        guard let collectionView = collectionView else { return }
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        let lastIndexPath = IndexPath(item: numberOfItems - 1, section: 0)
        if numberOfItems >= 1 {
            collectionView.scrollToItem(at: lastIndexPath, at: UICollectionViewScrollPosition.bottom, animated: true)
        }
    }
    
    // Although unnecessary, I explicitly marked this method as "internal" because it's made visible for obj-c #selector
    internal func handleKeyboardNotification(notification: Notification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            bottomConstraint?.constant = isKeyboardShowing ? -(keyboardFrame?.height)! : 0
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                if isKeyboardShowing {
                    self.scrollToLastCellItem()
                }
            })
        }
    }
    
    fileprivate func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    fileprivate func setupInputComponent() {
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        messageInputContainerView.addSubview(topBorderView)
        messageInputContainerView.addConstraintsWithFormat(format: "H:|-8-[v0][v1(60)]|", views: inputTextField, sendButton)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: inputTextField)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: sendButton)
        messageInputContainerView.addConstraintsWithFormat(format: "H:|[v0]|", views: topBorderView)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0(1)]", views: topBorderView)
    }
    
    fileprivate func setupMessageInputContainerView() {
        view.addSubview(messageInputContainerView)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: messageInputContainerView)
        view.addConstraintsWithFormat(format: "V:[v0(48)]", views: messageInputContainerView)
        bottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
        setupInputComponent()
    }
    
    fileprivate func setupTabBar() {
        guard let tabBar = tabBarController?.tabBar else { return }
        tabBar.isHidden = true
    }
    
    fileprivate func setupNavigationController() {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 64, height: 32))
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.text = selectedUserName!
        titleLabel.textColor = UIColor.white
        self.navigationItem.titleView = titleLabel
    }
    
    fileprivate func setupCollectionView() {
        self.collectionView?.backgroundColor = UIColor.midNightBlack()
    }
    
}


// MARK: - Lifecycle

extension DetailViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupCollectionView()
        setupMessageInputContainerView()
        setupKeyboardNotifications()
        setupTextFieldDelegate()
        setupCollectionViewGesture()
        setupNavigationController()
    }
    
}


// MARK: - UICollectionViewDelegateFlowLayout

extension DetailViewController: UICollectionViewDelegateFlowLayout {
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionViewLayout.invalidateLayout()
    }
    
}


// MARK: - UITextFieldDelegate

extension DetailViewController: UITextFieldDelegate {
    
    func setupTextFieldDelegate() {
        inputTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputTextField.resignFirstResponder()
        return true
    }
    
    func setupCollectionViewGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(collectionViewTapped(recognizer: )))
        collectionView?.addGestureRecognizer(gesture)
    }
    
    func collectionViewTapped(recognizer: UIGestureRecognizer) {
        inputTextField.resignFirstResponder()
    }
    
}


// MARK: - Parse

extension DetailViewController {
    
    func downloadMessageFromParse(with selectedUserName: String, completion: @escaping ([PFObject]) -> Void) {
        guard let query = Message.query(receiverName: selectedUserName, senderName: (PFUser.current()?.username)!) else { return }
        query.findObjectsInBackground { (pfObjects: [PFObject]?, error: Error?) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                guard let pfObjects = pfObjects else {
                    print("updateCoreMessageFromParse - pfObjects are nil")
                    return
                }
                completion(pfObjects)
            }
        }
    }
    
    func uploadToParse(with sms: String, completion: @escaping (Message) -> Void) {
        let pfObject = Message()
        pfObject["sms"] = sms
        pfObject["image"] = ""
        pfObject["senderName"] = selectedUserName!
        pfObject["receiverName"] = (PFUser.current()?.username)!
        pfObject.saveInBackground { (completed: Bool, error: Error?) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                if completed == true {
                    completion(pfObject)
                }
            }
        }
    }
    
}



















