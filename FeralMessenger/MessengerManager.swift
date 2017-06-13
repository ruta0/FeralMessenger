//
//  MessengerManager.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/12/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import Parse
import AVFoundation


protocol MessengerManagerDelegate {
    func didReceiveMessage(from sender: String, with message: Message)
    func didSendMessage(to receiver: String, with message: Message)
}

extension MessengerManagerDelegate {
    func didReceiveInvitation() {}
    func didSendInvitation() {}
    func didChangeRelationship() {}
}


class MessengerManager: NSObject {
    
    var player: AVAudioPlayer?
    var delegate: MessengerManagerDelegate?
    
    func createMessageInParse(with sms: String, receiverName: String, completion: @escaping (Message) -> Void) {
        let message = Message()
        message["sms"] = sms
        message["image"] = ""
        message["senderName"] = PFUser.current()?.username!
        message["receiverName"] = receiverName
        message.saveInBackground { [weak self] (completed: Bool, error: Error?) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                if completed == true {
                    completion(message)
                    self?.playSound()
                    self?.delegate?.didSendMessage(to: receiverName, with: message)
                }
            }
        }
    }
    
    private func playSound() {
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
    
    override init() {
        // implement this
        super.init()
    }
    
    deinit {
    }
    
}





















