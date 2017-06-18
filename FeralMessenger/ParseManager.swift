//
//  MessengerManager.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/12/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import Parse


// MARK: - Protocols

protocol ParseUsersManagerDelegate {
    func didReceiveUsers(with users: [PFObject]) // update local persistent container and handle UI
}


protocol ParseMessengerManagerDelegate {
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
}


// MARK: - Parse Manager

/// This class handles the communication between the client and the parse server
class ParseManager: NSObject {
    
    // MARK: - Create
    
    func createMessageInParse(with sms: String, receiverID: String) {
        let message = Message()
        message.constructMessageInfo(sms: sms, receiverID: receiverID, senderID: PFUser.current()!.objectId!)
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
    
    // MARK: - Read
    
    func readUsersInParse(with predicate: NSPredicate?, completion: @escaping ([PFObject]?) -> Void) {
        guard let query = User.defaultQuery(with: predicate) else {
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
    
    func readMessagesInParse(with receiverID: String, completion: @escaping ([PFObject]?) -> Void) {
        guard let query = Message.query(receiverID: receiverID, senderID: PFUser.current()!.objectId!) else {
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
    
    // MARK: - Update
    
    // MARK: - Destroy
    
    // when the user is not on the MessageViewController, use this handle to at AppDelegate to update the UI of NotificationViewController
    func didReceiveAPNSNotification() {
        // implement this
    }
    
    // MARK: - Lifecycle
    
    var userDelegate: ParseUsersManagerDelegate?

    var messengerDelegate: ParseMessengerManagerDelegate?
    
}

















