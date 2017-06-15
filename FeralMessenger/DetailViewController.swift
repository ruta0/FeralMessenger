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


class DetailViewController: UIViewController {
    
    // MARK: - UI
    
    var player: AVAudioPlayer?
    
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var footerLabel: UILabel!

    @IBOutlet weak var heightContraint: NSLayoutConstraint!
    
    lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = UIColor.white
        return control
    }()
    
    lazy var titleButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor.white
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 25)
        button.setTitle("Message", for: UIControlState.normal)
        return button
    }()
    
    lazy var profileButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor.white
        button.setBackgroundImage(UIImage(named: "Cat")!, for: UIControlState.normal)
        button.layer.cornerRadius = 16.5
        button.clipsToBounds = true
        button.contentMode = UIViewContentMode.scaleAspectFill
        button.frame = CGRect(x: 0, y: 0, width: 33, height: 33)
        return button
    }()
    
    @IBAction func sendButton_tapped(_ sender: UIButton) {
        let message = messageTextField.text
        clearMessageTextField()
        // handle sending message
        if let sms = message, !sms.isEmpty, let receiverName = receiverName {
            manager?.createMessageInParse(with: sms, receiverName: receiverName)
        }
    }
    
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
    
    func beginRefresh() {
        DispatchQueue.main.async {
            self.refreshControl.beginRefreshing()
        }
    }
    
    func endRefresh() {
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
    }
    
    func clearMessageTextField() {
        DispatchQueue.main.async {
            self.messageTextField.text?.removeAll()
        }
    }
    
    func setupNavigationController() {
        // title
        navigationItem.titleView = titleButton
        // rightBarButton
        navigationItem.rightBarButtonItems = [UIBarButtonItem(customView: profileButton)]
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
    
    // MARK: - Lifecycle
    
    @IBOutlet weak var tableView: UITableView!
    
    var receiverName: String?
    
    var parseMessages = [PFObject]()
    
    var manager: ParseManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupInputContainerView()
        setupNavigationController()
        setupFooterView()
        manager = ParseManager()
        if let receiverName = receiverName {
            manager?.readMessagesInParse(with: receiverName, completion: { (messages: [PFObject]?) in
                guard let messages = messages else { return }
                self.parseMessages = messages
            })
        } else {
            print("receiverName is nil")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeKeyboardNotifications()
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


// MARK: - Keyboard

extension DetailViewController {
    
    func scrollToLastCellItem() {
        let numberOfRows = tableView.numberOfRows(inSection: 0)
        let lastIndexPath = IndexPath(item: numberOfRows - 1, section: 0)
        if numberOfRows >= 1 {
            DispatchQueue.main.async {
                self.tableView.scrollToRow(at: lastIndexPath, at: UITableViewScrollPosition.bottom, animated: true)
            }
        }
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
    
    func tableViewTapped(recognizer: UIGestureRecognizer) {
        messageTextField.resignFirstResponder()
    }
    
    fileprivate func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    fileprivate func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
}



















