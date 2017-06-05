//
//  DetailViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/20/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import Parse
import AVFoundation


// MARK: - UI

class DetailViewController: FetchedResultsViewController {
    
    var player: AVAudioPlayer?
    
    var bottomConstraint: NSLayoutConstraint?
    var selectedUser: CoreUser?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
    
    lazy var titleButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor.white
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 25)
        return button
    }()
    
    lazy var profileButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor.white
        button.setBackgroundImage(UIImage(named: "Cat")!, for: UIControlState.normal)
        button.layer.cornerRadius = 16.5
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(presentProfileViewController(_:)), for: UIControlEvents.touchUpInside)
        button.contentMode = UIViewContentMode.scaleAspectFill
        button.frame = CGRect(x: 0, y: 0, width: 33, height: 33)
        return button
    }()
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = UIColor.white
        textField.backgroundColor = UIColor.clear
        textField.attributedPlaceholder = NSAttributedString(string: "Message", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        textField.keyboardAppearance = UIKeyboardAppearance.dark
        textField.delegate = self
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
    
    func playSound() {
        guard let sound = NSDataAsset(name: "sent") else {
            print("sound file not found")
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(data: sound.data, fileTypeHint: AVFileTypeWAVE)
            guard let player = player else { return }
            player.play()
        } catch let err {
            print(err.localizedDescription)
        }
    }
    
    func sendMessage() {
        self.activityIndicator.startAnimating()
    }
    
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
    
    fileprivate func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
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
        // title
        navigationItem.titleView = titleButton
        titleButton.setTitle(selectedUser?.username!, for: UIControlState.normal)
        // rightBarButton
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: profileButton)]
        if let profileImage = selectedUser?.profile_image, let image = UIImage(named: profileImage) {
            profileButton.setImage(image, for: UIControlState.normal)
        }
    }
    
    fileprivate func setupCollectionView() {
        guard let collectionView = collectionView else { return }
        collectionView.backgroundColor = UIColor.midNightBlack()
    }
    
}


// MARK: - Lifecycle

extension DetailViewController {
    
    internal func presentProfileViewController(_ sender: UIButton) {
        print("Not supported at this moment")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupCollectionView()
        setupMessageInputContainerView()
        setupKeyboardNotifications()
        setupCollectionViewGesture()
        setupNavigationController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        removeKeyboardNotifications()
    }
    
}


// MARK: - UICollectionViewDelegateFlowLayout

extension DetailViewController: UICollectionViewDelegateFlowLayout {
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let edgeInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
        return edgeInset
    }
    
}


// MARK: - UITextFieldDelegate

extension DetailViewController: UITextFieldDelegate {
    
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
    
    func readMessageInParse(with selectedUserName: String, completion: @escaping ([PFObject]) -> Void) {
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
    
    func createMessageInParse(with sms: String, completion: @escaping (Message) -> Void) {
        let pfObject = Message()
        pfObject["sms"] = sms
        pfObject["image"] = ""
        pfObject["senderName"] = PFUser.current()?.username!
        pfObject["receiverName"] = selectedUser?.username!
        pfObject.saveInBackground { [weak self] (completed: Bool, error: Error?) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                if completed == true {
                    completion(pfObject)
                    self?.playSound()
                }
            }
        }
    }
    
}



















