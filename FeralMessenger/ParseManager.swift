//
//  MessengerManager.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/12/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import Parse


protocol ParseUsersManagerDelegate {
    func didReceiveUsers(with users: [PFObject]) // update local persistent container and handle UI
}


protocol ParseMessengerManagerDelegate {
    func registerForLocalNotifications() // add observers to listen APNS in AppDelegate
    func unregisterForLocalNotifications() // remove observers for APNS in AppDelegate
    func didReceiveMessages(with messages: [PFObject]) // fetched an array of messages, handle UI
    func didReceiveMessage(with message: Message) // update local persistent container and handle UI
    func didSendMessage(with message: Message) // update local persistent container and handle UI
}

// [development]
extension ParseMessengerManagerDelegate {
    func didReceiveInvitation() {} // handle UI
    func didSendInvitation() {} // ignore
    func invitationAccepted() {} // update relationship in Parse Server and local persistent container and handle UI
    func invitationRejected() {} // handle UI
    func didCreatAPNSNotification() {} // ignore
    func didDestroyAPNSNotification() {} // update local persistent container and handle UI
}


/// This class handles the communication between the client and the parse server
class ParseManager: NSObject {
    
    // MARK: - Parse
    
    func readUsersInParse(with predicate: NSPredicate?, completion: @escaping ([PFObject]?) -> Void) {
        guard let query = User.query(with: predicate) else {
            print("query is nil")
            return
        }
        query.findObjectsInBackground { [weak self] (users: [PFObject]?, error: Error?) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                completion(users)
                guard let users = users else {
                    print("users: [PFObject] are nil")
                    return
                }
                self?.userDelegate?.didReceiveUsers(with: users)
            }
        }
    }
    
    func readMessagesInParse(with receiverName: String, completion: @escaping ([PFObject]?) -> Void) {
        guard let query = Message.query(receiverName: receiverName, senderName: (PFUser.current()?.username)!) else {
            print("query is nil")
            return
        }
        query.findObjectsInBackground { [weak self] (messages: [PFObject]?, error: Error?) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                completion(messages)
                guard let messages = messages else {
                    print("messages: [PFObject] are nil")
                    return
                }
                self?.messengerDelegate?.didReceiveMessages(with: messages)
            }
        }
    }
    
    func createMessageInParse(with sms: String, receiverName: String) {
        let message = Message()
        message["sms"] = sms
        message["image"] = ""
        message["senderName"] = PFUser.current()?.username!
        message["receiverName"] = receiverName
        message.saveInBackground { (completed: Bool, error: Error?) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                if completed == true {
                    self.messengerDelegate?.didSendMessage(with: message)
                }
            }
        }
    }
    
    // MARK: - APNS
    
    // create a FPPush to notifify the other user
    private func createAPNSNotification(with message: Message) {
        // implement this
        messengerDelegate?.didCreatAPNSNotification()
    }
    
    // when a APNS is read, destroy it in Parse Server
    private func destroyAPNSNotification(with pushMessage: PFPush) {
        // implement this
        messengerDelegate?.didDestroyAPNSNotification()
    }
    
    // when the user is not on the MessageViewController, use this handle to at AppDelegate to update the UI of NotificationViewController
    func didReceiveAPNSNotification() {
        // implement this
    }
    
    // when the user is talking to someone in MessageViewController, register observers to listen to APNS frpm AppDelegate's NotificationCenter post
    func registerForSubscription() {
        // implement this
    }
    
    // when MessageViewController viewDidDisappear() remove all observers
    func unregisterForSubscription() {
        // implement this
    }
    
    // MARK: - Lifecycle
    
    var userDelegate: ParseUsersManagerDelegate?

    var messengerDelegate: ParseMessengerManagerDelegate?
    
    override init() {
        super.init()
        // implement this
        messengerDelegate?.registerForLocalNotifications()
    }
    
    deinit {
        // implement this
        messengerDelegate?.unregisterForLocalNotifications()
    }
    
}

















