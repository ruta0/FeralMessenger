//
//  DetailCell.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/20/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit


class DetailCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
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
        profileImageView?.image = nil
        // STEP 2: load new info from user (if any)
        if let coreMessage = self.coreMessage {
            // implement profile_image
            messageTextView.text = coreMessage.sms
            profileImageView.image = #imageLiteral(resourceName: "ProfileImage")
        }
    }
    
    private func setupViews() {
        // collectionViewCell
        backgroundColor = UIColor.clear
        // profileImage
        profileImageView.layer.cornerRadius = 15
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.masksToBounds = true
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
        addSubview(profileImageView)
        addConstraintsWithFormat(format: "H:|-8-[v0(30)]", views: profileImageView)
        addConstraintsWithFormat(format: "V:[v0(30)]|", views: profileImageView)
    }
    
}
