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
    func didLogin(pfUser: PFUser?, error: Error?)
    func didSignup(completed: Bool, error: Error?)
    func didReadUsers(with users: [PFObject]?, error: Error?)
    func didDestroyCurrentUser(completed: Bool, error: Error?)
    func didUpdateCurrentUser(completed: Bool, error: Error?)
    func didAddFriend(completed: Bool, error: Error?)
    func didRemoveFriend(completed: Bool, error: Error?)
}

extension ParseUsersManagerDelegate {
    func didLogin(pfUser: PFUser?, error: Error?) {}
    func didSignup(completed: Bool, error: Error?) {}
    func didReadUsers(with users: [PFObject]?, error: Error?) {}
    func didDestroyCurrentUser(completed: Bool, error: Error?) {}
    func didUpdateCurrentUser(completed: Bool, error: Error?) {}
    func didAddFriend(completed: Bool, error: Error?) {}
    func didRemoveFriend(completed: Bool, error: Error?) {}
}

// MARK: - ParseMessengerManagerDelegate protocol

protocol ParseMessengerManagerDelegate {
    func didReceiveMessages(with messages: [PFObject]?, error: Error?)
    func didReceiveMessage(with message: Message, error: Error?)
    func didSendMessage(with message: Message, error: Error?)
}

extension ParseMessengerManagerDelegate {
    func didReceiveInvitation() {} // handle UI
    func didSendInvitation() {} // ignore
    func invitationAccepted(senderID: String, receiverID: String) {} // update relationship in Parse Server and local persistent container and handle UI
    func invitationRejected(senderID: String, receiverID: String) {} // handle UI
}


var isParseInitialized: Bool = false

/// This class handles the communication between the client and the parse server
class ParseManager: NSObject {
    
    var userDelegate: ParseUsersManagerDelegate?
    
    var messengerDelegate: ParseMessengerManagerDelegate?
    
    var currentUser: PFUser {
        guard let user = PFUser.current() else {
            fatalError("current user cannot be nil")
        }
        return user
    }
    
    // MARK: - Create
    
    func signup(with name: String, email: String, pass: String) {
        let lowerCasedEmail = email.lowercased()
        let newUser = User()
        newUser.constructUserInfo(name: name, email: lowerCasedEmail, pass: pass)
        newUser.signUpInBackground { [weak self] (completed: Bool, err: Error?) in
            self?.userDelegate?.didSignup(completed: completed, error: err)
        }
    }
    
    func addFriend(with id: String) {
        guard var friends = currentUser["friends"] as? [String] else {
            print("current user is nil")
            return
        }
        friends.append(id)
        currentUser["friends"] = friends
        print(currentUser)
        currentUser.saveInBackground { [weak self] (completed: Bool, err: Error?) in
            self?.userDelegate?.didAddFriend(completed: completed, error: err)
        }
    }
    
    func sendMessage(with sms: String, receiverID: String, senderID: String, completion: @escaping (Bool, Error?) -> Void) {
        let message = Message()
        message.constructMessageInfo(sms: sms, receiverID: receiverID, senderID: senderID)
        message.saveInBackground { [weak self] (completed: Bool, err: Error?) in
            completion(completed, err)
            self?.messengerDelegate?.didSendMessage(with: message, error: err)
        }
    }
    
    // MARK: - Read
    
    func readFriends() {
        var friends = [PFObject]()
        guard let ids = currentUser["friends"] as? [String] else {
            print("Invalid friends field")
            return
        }
        let dispatchGroup = DispatchGroup()
        for id in ids {
            dispatchGroup.enter()
            guard let query = User.query() else { return }
            query.getObjectInBackground(withId: id, block: { (result: PFObject?, error: Error?) in
                if let err = error {
                    print(err.localizedDescription)
                } else {
                    guard let friend = result else { return }
                    friends.append(friend)
                    dispatchGroup.leave()
                }
            })
        }
        dispatchGroup.notify(queue: DispatchQueue.main) { [weak self] in
            self?.userDelegate?.didReadUsers(with: friends, error: nil)
        }
    }
    
    /// Wild card method to fetch all users
    func readAllUsers(with predicate: NSPredicate?) {
        guard let query = User.defaultQuery(with: predicate) else {
            print("query is nil")
            return
        }
        query.findObjectsInBackground { [weak self] (users: [PFObject]?, err: Error?) in
            self?.userDelegate?.didReadUsers(with: users, error: err)
        }
    }
    
    func readMessages(with receiverID: String) {
        guard let query = Message.query(receiverID: receiverID, senderID: currentUser.objectId!) else {
            print("query is nil")
            return
        }
        query.findObjectsInBackground { [weak self] (messages: [PFObject]?, error: Error?) in
            self?.messengerDelegate?.didReceiveMessages(with: messages, error: error)
        }
    }
    
    /// Make sure to attemptToInitializeParse first!
    func login(token: String) {
        PFUser.become(inBackground: token) { [weak self] (pfUser: PFUser?, error: Error?) in
            self?.userDelegate?.didLogin(pfUser: pfUser, error: error)
        }
    }
    
    /// Make sure to attemptToInitializeParse first!
    func login(user: String, pass: String) {
        PFUser.logInWithUsername(inBackground: user, password: pass) { [weak self] (pfUser: PFUser?, error: Error?) in
            self?.userDelegate?.didLogin(pfUser: pfUser, error: error)
        }
    }
    
    // MARK: - Update
    
    /// update currentUser's field: String, that is not "friends", async. i.e. bio and avatar
    func updateUser(for field: String, newValue: String) {
        currentUser[field] = newValue
        currentUser.saveInBackground { [weak self] (completed: Bool, err: Error?) in
            self?.userDelegate?.didUpdateCurrentUser(completed: completed, error: err)
        }
    }
    
    func updatePassword(with newPass: String) {
        currentUser.password = newPass
        currentUser.saveInBackground { [weak self] (completed: Bool, err: Error?) in
            self?.userDelegate?.didUpdateCurrentUser(completed: completed, error: err)
        }
    }
    
    func updateEmail(with newEmail: String) {
        currentUser.email = newEmail.lowercased()
        currentUser.saveInBackground { [weak self] (completed: Bool, err: Error?) in
            self?.userDelegate?.didUpdateCurrentUser(completed: completed, error: err)
        }
    }
    
    // MARK: - Destroy
    
    func destroyCurrentUser() {
        currentUser.deleteInBackground { [weak self] (completed: Bool, err: Error?) in
            self?.userDelegate?.didDestroyCurrentUser(completed: completed, error: err)
        }
    }
    
    func removeFriend(with id: String) {
        guard let friends = currentUser["friends"] as? [String] else {
            print("current user is nil")
            return
        }
        let updatedFriends = friends.filter { $0 != id }
        currentUser["friends"] = updatedFriends
        print(updatedFriends)
        currentUser.saveInBackground { [weak self] (completed: Bool, err: Error?) in
            self?.userDelegate?.didRemoveFriend(completed: completed, error: err)
        }
    }
    
    // MARK: - Server
    
    func attemptToInitializeParse() {
        if isParseInitialized == false {
            Parse.initialize(with: ParseServerConfiguration.config)
            isParseInitialized = true
        }
    }
    
    func saveDeviceToken(with token: Data, completion: @escaping ((Bool, Error?) -> Void)) {
        if let installation = PFInstallation.current() {
            installation.setDeviceTokenFrom(token)
            installation.saveInBackground(block: { (completed: Bool, err: Error?) in
                completion(completed, err)
            })
        } else {
            print("current installation is nil")
        }
    }
    
}

















