//
//  MessengerManager.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/12/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import Parse

// MARK: - ParseUsersManagerDelegate protocol

protocol ParseUsersManagerDelegate {
    
    func didReceiveUsers(with users: [PFObject]) // update local persistent container and handle UI
}

// MARK: - ParseMessengerManagerDelegate protocol

protocol ParseMessengerManagerDelegate {
    
    func didReceiveMessages(with messages: [PFObject]) // fetched an array of messages, handle UI
    func didReceiveMessage(with message: Message) // update local persistent container and handle UI
    func didSendMessage(with message: Message) // update local persistent container and handle UI
}

// [development]
// MARK: - Optional ParseMessengerManagerDelegate protocol methods

extension ParseMessengerManagerDelegate {
    
    func didReceiveInvitation() {} // handle UI
    func didSendInvitation() {} // ignore
    func invitationAccepted(senderID: String, receiverID: String) {} // update relationship in Parse Server and local persistent container and handle UI
    func invitationRejected(senderID: String, receiverID: String) {} // handle UI
    
}


/// This class handles the communication between the client and the parse server
class ParseManager: NSObject {
    
    // MARK: - Create
    
    func createMessageInParse(with sms: String, receiverID: String, senderID: String) {
        let message = Message()
        message.constructMessageInfo(sms: sms, receiverID: receiverID, senderID: senderID)
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
    
    /// fetching a list of friends id
    private func getFriendIDs() -> [String] {
        guard let currentUser = PFUser.current(), let friends = currentUser["friends"] as? [String] else {
            fatalError("Invalid current user or friends field")
        }
        return friends
    }
    
    func readFriends() {
        var friends = [PFObject]()
        let ids = getFriendIDs()
        if !ids.isEmpty {
            for id in ids {
                guard let query = User.defaultQuery(with: nil) else { return }
                let task = query.getObjectInBackground(withId: id)
                if let result = task.result {
                    print(result)
                    friends.append(result)
                }
            }
        }
        print(friends)
    }
    
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

















