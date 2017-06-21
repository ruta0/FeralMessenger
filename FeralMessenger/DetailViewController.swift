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
import CloudKit


class DetailViewController: UIViewController {
    
    // MARK: - NavigationController
    
    var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        view.hidesWhenStopped = true
        return view
    }()
    
    var titleButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor.white
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 25)
        return button
    }()
    
    func beginLoadingAnime() {
        DispatchQueue.main.async {
            self.view.layoutIfNeeded()
            self.navigationItem.titleView = self.activityIndicator
            self.activityIndicator.startAnimating()
        }
    }
    
    func stopLoadingAnime() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.navigationItem.titleView = self.titleButton
        }
    }
    
    var rightBarButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor.white
        button.layer.cornerRadius = 16.5
        button.clipsToBounds = true
        button.contentMode = UIViewContentMode.scaleAspectFill
        button.frame = CGRect(x: 0, y: 0, width: 33, height: 33)
        return button
    }()
    
    func setupNavigationController() {
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: rightBarButton)]
    }
    
    // MARK: - InputContainerView
    
    var keyboardManager: KeyboardManager?
    
    var player: AVAudioPlayer?
    
    @IBOutlet weak var heightContraint: NSLayoutConstraint!
    
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBAction func sendButton_tapped(_ sender: UIButton) {
        let message = messageTextField.text
        clearMessageTextField()
        // sending message
        if let sms = message, !sms.isEmpty, let receiverID = receiverID {
            parseManager?.createMessageInParse(with: sms, receiverID: receiverID, senderID: PFUser.current()!.objectId!)
        }
    }
    
    // schwoof
    func playSound() {
        guard let sound = NSDataAsset(name: "sent") else {
            print("sound file not found")
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(data: sound.data, fileTypeHint: AVFileTypeWAVE)
            DispatchQueue.main.async {
                guard let player = self.player else { return }
                player.play()
            }
        } catch let err {
            print(err.localizedDescription)
        }
    }
    
    func clearMessageTextField() {
        DispatchQueue.main.async {
            self.messageTextField.text?.removeAll()
        }
    }
    
    private func setupInputContainerView() {
        // inputContainerView
        inputContainerView.backgroundColor = UIColor.midNightBlack()
        // dividerView
        dividerView.backgroundColor = UIColor.mediumBlueGray()
        // messageTextField
        messageTextField.backgroundColor = UIColor.clear
        messageTextField.attributedPlaceholder = NSAttributedString(string: "Message", attributes: [NSForegroundColorAttributeName: UIColor.darkGray])
        messageTextField.delegate = self
        // sendButton
        sendButton.backgroundColor = UIColor.clear
    }
    
    // MARK: - TableView
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableViewTapped(recognizer: UIGestureRecognizer) {
        messageTextField.resignFirstResponder()
    }
    
    // this method is still very buggy
    func scrollToLastCellItem() {
        let numberOfRows = tableView.numberOfRows(inSection: 0)
        let lastIndexPath = IndexPath(row: numberOfRows - 1, section: 0)
        if numberOfRows >= 1 && tableView.visibleCells.count > 1 {
            DispatchQueue.main.async {
                self.tableView.scrollToRow(at: lastIndexPath, at: UITableViewScrollPosition.bottom, animated: true)
            }
        }
    }
    
    fileprivate func setupTableView() {
        tableView.delegate = self
        tableView.backgroundColor = UIColor.midNightBlack()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped(recognizer:)))
        tableView.addGestureRecognizer(gesture)
    }
    
    // MARK: - CloudKit
    
    var ckManager: CloudKitManager?
    
    func setupCKManager() {
        ckManager = CloudKitManager()
    }
    
    let pubDatabase = CKContainer.default().publicCloudDatabase
    
    let subscriptionID = "iCloud_Messages_Notification_Creations_Updates_Deletions"
    
    // MARK: - Parse
    
    var parseManager: ParseManager?
    
    var receiverID: String? // initiated by previous viewController at prepareForSegue()
    
    func setupParseManager() {
        parseManager = ParseManager()
    }
    
    func fetchMessages() {
        if let receiverID = receiverID {
            beginLoadingAnime()
            parseManager?.readMessagesInParse(with: receiverID, completion: { (messages: [PFObject]?) in
                self.stopLoadingAnime()
            })
        } else {
            print("receiverID is nil")
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // UI
        setupTableView()
        setupInputContainerView()
        setupNavigationController()
        // Parse
        setupParseManager() // 1
        fetchMessages() // 2
        // CloudKit
        setupCKManager()
        // Keyboard
        setupKeyboardManager()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ckManager?.subscribeToRecord(database: pubDatabase, subscriptionID: subscriptionID, dynamicRecordType: PFUser.current()!.username!)
        ckManager?.setupLocalObserver()
        keyboardManager?.setupKeyboardDockableNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ckManager?.unsubscribeToRecord(database: pubDatabase, subscriptionID: subscriptionID)
        ckManager?.removeLocalObserver(observer: self)
        keyboardManager?.removeKeyboardNotifications()
    }
    
}


// MARK: - UITableViewDelegate

extension DetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(84)
    }
    
}


// MARK: - UITableViewDataSource

extension DetailViewController: UITableViewDataSource {
    
    // override this
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    // override this
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // override this
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
}


// MARK: - UITextFieldDelegate

extension DetailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}


// MARK: - KeyboardDockableDelegate

extension DetailViewController: KeyboardDockableDelegate {
    
    func setupKeyboardManager() {
        keyboardManager = KeyboardManager()
        keyboardManager?.dockableDelegate = self
    }
    
    func keyboardDidChangeFrame(from notification: Notification, in keyboardRect: CGRect) {
        let keyboardWillShow = (notification.name == NSNotification.Name.UIKeyboardWillShow)
        heightContraint.constant = keyboardWillShow ? (inputContainerView.frame.size.height + keyboardRect.height) : 50
        UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }) { (completed: Bool) in
            if keyboardWillShow {
                self.scrollToLastCellItem()
            }
        }
    }
    
}


