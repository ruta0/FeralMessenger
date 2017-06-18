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
            parseManager?.createMessageInParse(with: sms, receiverID: receiverID)
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
            guard let player = player else { return }
            player.play()
        } catch let err {
            print(err.localizedDescription)
        }
    }
    
    func clearMessageTextField() {
        DispatchQueue.main.async {
            self.messageTextField.text?.removeAll()
        }
    }
    
    fileprivate func setupInputContainerView() {
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
    
    fileprivate func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    fileprivate func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // MARK: - TableView
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var footerLabel: UILabel!
    
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
    
    fileprivate func setupFooterView() {
        // footerView
        footerView.backgroundColor = UIColor.midNightBlack()
        // footerTextField
        footerLabel.backgroundColor = UIColor.midNightBlack()
    }
    
    fileprivate func setupTableView() {
        tableView.delegate = self
        tableView.backgroundColor = UIColor.midNightBlack()
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped(recognizer:)))
        tableView.addGestureRecognizer(gesture)
    }
    
    // MARK: - CloudKit
    
    var ckManager: CloudKitManager?
    
    let pubDatabase = CKContainer.default().publicCloudDatabase
    
    private var cloudKitObserver: NSObjectProtocol?
    
    let subscriptionID = "iCloud_Messages_Notification_Creations_Deletions"
    
    func setupCloudKitObserver() {
        // listen to the notification coming from AppDelegate
        cloudKitObserver = NotificationCenter.default.addObserver(forName: Notification.Name(CloudKitNotifications.NotificationReceived), object: nil, queue: OperationQueue.main, using: { (notification: Notification) in
            if let ckqn = notification.userInfo?[CloudKitNotifications.NotificationKey] as? CKQueryNotification {
                self.iCloudHandleSubscriptionNotification(ckqn: ckqn)
            }
        })
    }
    
    func removeCloudKitObserver() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name(CloudKitNotifications.NotificationReceived), object: nil)
    }
    
    private func iCloudHandleSubscriptionNotification(ckqn: CKQueryNotification) {
        if ckqn.subscriptionID == self.subscriptionID {
            if let recordID = ckqn.recordID {
                switch ckqn.queryNotificationReason {
                case .recordCreated:
                    pubDatabase.fetch(withRecordID: recordID, completionHandler: { (ckRecord: CKRecord?, err: Error?) in
                        // if a record cannot be fetched, just fetch a new batch of messages from Parse Server and tableView.reload()
                        // if fetch is success, either show a remote notification+change ChatsViewController's border color || reload tableView if the user is at MessageViewController
                        print(ckRecord!)
                    })
                case .recordDeleted:
                    // when a user did read the push notification, delete it on iCloud and then handle UI
                    ckManager?.deleteCKRecord()
                default:
                    break
                }
            }
        }
    }
    
    // MARK: - Lifecycle
    
    var parseManager: ParseManager?
    
    var receiverID: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupInputContainerView()
        setupNavigationController()
        setupFooterView()
        // Parse
        parseManager = ParseManager()
        if let receiverID = receiverID {
            beginLoadingAnime()
            parseManager?.readMessagesInParse(with: receiverID, completion: { (messages: [PFObject]?) in
                self.stopLoadingAnime()
            })
        } else {
            print("receiverID is nil")
        }
        // CloudKit
        ckManager = CloudKitManager()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupKeyboardNotifications()
        ckManager?.subscribeToMessage(database: pubDatabase, subscriptionID: subscriptionID)
        setupCloudKitObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeKeyboardNotifications()
        ckManager?.unsubscribeToMessage(database: pubDatabase, subscriptionID: subscriptionID)
        removeCloudKitObserver()
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
}


// MARK: - UITextFieldDelegate

extension DetailViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}


















