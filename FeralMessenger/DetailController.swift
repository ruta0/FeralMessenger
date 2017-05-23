//
//  DetailController.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/22/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import Parse


extension DetailViewController {
    
    func fetchMessages(receiverName: String) {
        guard let query = Message.query(receiverName: receiverName, senderName: (PFUser.current()?.username)!) else { return }
        query.findObjectsInBackground { (pfObjects: [PFObject]?, error: Error?) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                guard let pfObjects = pfObjects else { return }
                for pfObject in pfObjects {
                    let message = Message()
                    message.sms = pfObject["sms"] as? String
                    self.messages.append(message)
                }
                self.reloadData()
            }
        }
    }
    
    func reloadData() {
        collectionView?.reloadData()
    }
    
    func sendMessage() {
        if let sms = inputTextField.text, sms != "" {
            pushMessageToParse(sms: inputTextField.text!) // asynchronous
            clearTextField()
        }
    }
    
    func pushMessageToParse(sms: String) {
        let pfObject = Message(image: nil, senderName: (PFUser.current()?.username)!, receiverName: selectedUser.username!, sms: sms)
        pfObject.sms = sms
        pfObject.saveInBackground { (completed: Bool, error: Error?) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                if completed == true {
                    // perform ui changes on main queue
                    DispatchQueue.main.async {
                        self.messages.append(pfObject)
                        self.reloadData()
                    }
                }
            }
        }
    }
    
    func handleRefresh() {
        reloadData()
        refreshControl.endRefreshing()
    }
    
    func clearTextField() {
        inputTextField.text = ""
    }
    
}


























