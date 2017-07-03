//
//  MPCDetailsViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/7/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import MultipeerConnectivity


class MPCDetailViewContrller: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var messagesArray: [Dictionary<String, String>] = []
    var messages = [Array<CoreMessage>]() // this is better data structure
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func mpcManagerDidReceivedData(with notification: Notification) {
        let receivedData = notification.object as! Dictionary<String, AnyObject>
        let data = receivedData["data"] as? NSData
        let fromPeer = receivedData["fromPeer"] as! MCPeerID
        let dataDictionary = NSKeyedUnarchiver.unarchiveObject(with: data! as Data) as! Dictionary<String, String>
        if let message = dataDictionary["message"] {
            if message != "_end_chat_" {
                let messageDictionary: [String: String] = ["sender": fromPeer.displayName, "message": message]
                messagesArray.append(messageDictionary)
                OperationQueue.main.addOperation {
                    self.reloadTableView()
                }
            } else{
                let alert = UIAlertController(title: "", message: "\(fromPeer.displayName) ended this chat", preferredStyle: UIAlertControllerStyle.alert)
                let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action: UIAlertAction) in
                    self.appDelegate.mpcManager.session?.disconnect()
                    self.popViewController()
                })
                alert.addAction(ok)
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(mpcManagerDidReceivedData(with:)), name: NSNotification.Name("receivedMPCDataNotification"), object: nil)
    }
    
    // MARK: - UITableView
    
    @IBOutlet weak var tableView: UITableView!
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            if self.tableView.contentSize.height > self.tableView.frame.height {
                let updatedIndexPath = IndexPath(row: self.messagesArray.count - 1, section: 0)
                self.tableView.scrollToRow(at: updatedIndexPath, at: UITableViewScrollPosition.bottom, animated: true)
            }
        }
    }
    
    private func setupViews() {
        // tableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.midNightBlack()
        // inputContainerView
        inputContainerView.backgroundColor = UIColor.mediumBlueGray()
        // inputTextField
        inputTextField.backgroundColor = UIColor.clear
        inputTextField.attributedPlaceholder = NSAttributedString(string: "Message", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        inputTextField.keyboardAppearance = UIKeyboardAppearance.dark
        inputTextField.delegate = self
        // sendButton
        let originalImage = UIImage(named: "Send")
        let tintedImage = originalImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        sendButton.setBackgroundImage(tintedImage, for: UIControlState.normal)
        sendButton.tintColor = UIColor.white
        sendButton.contentMode = UIViewContentMode.scaleAspectFill
    }
    
    // MARK: - InputContainerView
    
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBAction func sendButton_tapped(_ sender: UIButton) {
        inputTextField.resignFirstResponder()
        let messageDictionary: [String : String] = ["message": inputTextField.text!]
        if appDelegate.mpcManager.sendData(dictionaryWithData: messageDictionary, toPeer: appDelegate.mpcManager.session?.connectedPeers[0] as! MCPeerID) {
            let dictionary: [String : String] = ["sender": appDelegate.mpcManager.myPeerId.displayName, "message": inputTextField.text!]
            messagesArray.append(dictionary)
            self.reloadTableView()
        } else {
            print("Could not send data")
        }
        inputTextField.text = ""
    }
    
    // MARK: - NavigationController
    
    @IBOutlet weak var exitButton: UIBarButtonItem!
    
    @IBAction func exitButton_tapped(_ sender: UIBarButtonItem) {
        let messageDictionary: [String : String] = ["message": "_end_chat_"]
        if appDelegate.mpcManager.sendData(dictionaryWithData: messageDictionary, toPeer: (appDelegate.mpcManager.session?.connectedPeers[0])!) {
            self.appDelegate.mpcManager.session?.disconnect()
            DispatchQueue.main.async(execute: {
                self.navigationController?.popViewController(animated: true)
            })
        }
    }
    
    // MARK: - Lifecycle
    
    fileprivate func popViewController() {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupTableViewGesture()
        setupObservers()
    }
    
    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MPCDetailCell.id, for: indexPath) as! MPCDetailCell
        let message = messagesArray[indexPath.row] as Dictionary<String, String>
        if let sender = message["sender"] {
            cell.usernameLabel.text = sender
        }
        if let sms = message["message"] {
            cell.smsTextView.text = sms
        }
        return cell
    }
    
    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func setupTableViewGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped(recognizer:)))
        tableView.addGestureRecognizer(gesture)
    }
    
    func tableViewTapped(recognizer: UIGestureRecognizer) {
        inputTextField.resignFirstResponder()
    }
    
    
}























