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
        query.findObjectsInBackground { [weak self] (pfObjects: [PFObject]?, error: Error?) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                guard let pfObjects = pfObjects else { return }
                for pfObject in pfObjects {
                    let sender = pfObject["senderName"] as! String
                    let receiver = pfObject["receiverName"] as! String
                    let sms = pfObject["sms"] as! String
                    let message = Message(image: nil, senderName: sender, receiverName: receiver, sms: sms)
                    self?.messages.append(message)
                }
                self?.reloadData()
            }
        }
    }
    
    func reloadData() {
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    func sendMessage() {
        if let sms = inputTextField.text, sms != "" {
            pushMessageToParse(sms: inputTextField.text!) // asynchronous
            clearTextField()
        }
    }
    
    func pushMessageToParse(sms: String) {
        let pfObject = Message(image: nil, senderName: (PFUser.current()?.username)!, receiverName: selectedUserName!, sms: sms)
        pfObject.sms = sms
        pfObject.saveInBackground { [weak self] (completed: Bool, error: Error?) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                if completed == true {
                    self?.pushMessageToCollectionView(message: pfObject)
                    self?.scrollToLastCellItem()
                }
            }
        }
    }
    
    func pushMessageToCollectionView(message: Message) {
        // perform ui changes on main queue
        DispatchQueue.main.async {
            self.messages.append(message)
            self.collectionView?.reloadData()
        }
    }
    
    func clearTextField() {
        inputTextField.text = ""
    }
    
}


























