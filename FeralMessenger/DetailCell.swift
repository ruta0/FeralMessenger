//
//  DetailCell.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/20/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit


class DetailCell: UICollectionViewCell {
    
    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    
    var coreMessage: CoreMessage? {
        didSet {
            updateCell()
        }
    }
    
    private func updateCell() {
        // STEP 1: reset any existing UI info/outlets, otherwise info will become misplaced
        messageTextView?.text = nil
        // STEP 2: load new info from user (if any)
        if let coreMessage = self.coreMessage {
            // implement profile_image
            messageTextView.text = coreMessage.sms
        }
    }
    
    private func setupViews() {
        // collectionViewCell
        backgroundColor = UIColor.clear
        // wrapperView
        wrapperView.backgroundColor = UIColor.clear
        // bubbleView
        bubbleView.backgroundColor = UIColor.miamiBlue()
        bubbleView.layer.cornerRadius = 15
        bubbleView.layer.masksToBounds = true
        // messageTextView
        messageTextView.textColor = UIColor.darkGray
        messageTextView.backgroundColor = UIColor.clear
        messageTextView.font = UIFont.systemFont(ofSize: 14)
        messageTextView.text = "message"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
        addSubview(bubbleView)
        addSubview(messageTextView)
    }
    
}
