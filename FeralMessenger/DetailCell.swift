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
