//
//  HomeCell.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/20/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit


class HomeCell: UICollectionViewCell {
    
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    private func setupViews() {
        // collectionViewCell
        self.backgroundColor = UIColor.candyWhite()
        self.dividerView.backgroundColor = UIColor.lightGray
        // profileImage
        profileImageView.layer.cornerRadius = 10
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.borderWidth = 2
        profileImageView.image = UIImage(named: "ProfileImage")
        // usernameLabel
        usernameLabel.textColor = UIColor.deepSeaBlue()
        usernameLabel.backgroundColor = UIColor.clear
        usernameLabel.text = "username"
        // messageLabel
        messageLabel.textColor = UIColor.darkGray
        messageLabel.backgroundColor = UIColor.clear
        messageLabel.text = "message"
    }
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.miamiBlue() : UIColor.candyWhite()
            usernameLabel.textColor = isHighlighted ? UIColor.white : UIColor.deepSeaBlue()
            messageLabel.textColor = isHighlighted ? UIColor.white : UIColor.darkGray
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
}


























