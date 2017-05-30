//
//  HomeCell.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/20/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit


class MasterCell: UICollectionViewCell {
    
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    
    var coreUser: CoreUser? {
        didSet {
            updateCell()
        }
    }
    
    private func updateCell() {
        // STEP 1: reset any existing UI info/outlets, otherwise info will become misplaced
        profileImageView?.image = nil
        usernameLabel?.text = nil
        messageLabel?.text = nil
        // STEP 2: load new info from user (if any)
        if let coreUser = self.coreUser {
            usernameLabel.text = coreUser.username
            messageLabel.text = coreUser.timezone
            profileImageView.image = #imageLiteral(resourceName: "ProfileImage")
        }
    }
    
    private func setupViews() {
        // collectionViewCell
        self.backgroundColor = UIColor.mediumBlueGray()
        // dividerView
        dividerView.backgroundColor = UIColor.lightGray
        // profileImage
        profileImageView.layer.cornerRadius = 10
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.borderWidth = 2
        profileImageView.image = UIImage(named: "ProfileImage")
        // usernameLabel
        usernameLabel.textColor = UIColor.white
        usernameLabel.backgroundColor = UIColor.clear
        usernameLabel.text = "username"
        // messageLabel
        messageLabel.textColor = UIColor.candyWhite()
        messageLabel.backgroundColor = UIColor.clear
        messageLabel.text = "message"
    }
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.miamiBlue() : UIColor.mediumBlueGray()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
}

























