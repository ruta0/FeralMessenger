//
//  HomeCell.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/20/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit


class MasterCell: UICollectionViewCell {
    
    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    var coreUser: CoreUser? {
        didSet {
            updateCell()
        }
    }
    
    private func updateCell() {
        // STEP 1: reset any existing UI info/outlets, otherwise info will become misplaced
        profileImageView?.image = nil
        usernameLabel?.text = nil
        bioLabel?.text = nil
        // STEP 2: load new info from user (if any)
        if let coreUser = self.coreUser {
            usernameLabel.text = coreUser.username
            bioLabel.text = coreUser.bio
            if let avatar = UIImage(named: coreUser.profile_image!) {
                profileImageView.image = avatar
            }
            profileImageView.image = UIImage(named: coreUser.profile_image!)
        }
    }
    
    private func setupViews() {
        // collectionViewCell
        backgroundColor = UIColor.clear
        // wrapperView
        wrapperView.backgroundColor = UIColor.mediumBlueGray()
        // profileImage
        profileImageView.layer.cornerRadius = 32
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.borderWidth = 2
        profileImageView.image = UIImage(named: "Cat")
        // usernameLabel
        usernameLabel.textColor = UIColor.white
        usernameLabel.backgroundColor = UIColor.clear
        usernameLabel.text = "username"
        // messageLabel
        bioLabel.textColor = UIColor.candyWhite()
        bioLabel.backgroundColor = UIColor.clear
        bioLabel.text = "bio"
    }
    
    override var isHighlighted: Bool {
        didSet {
            wrapperView.backgroundColor = isHighlighted ? UIColor.miamiBlue() : UIColor.mediumBlueGray()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
}


























