//
//  HomeCell.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/20/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit


class MasterCell: UITableViewCell {
    
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    static let id = "MasterCell"
    
    var coreUser: CoreUser? {
        didSet {
            updateCell()
        }
    }
    
    private func updateCell() {
        // STEP 1: reset any existing UI info/outlets, otherwise info will become misplaced
        avatarImageView?.image = nil
        titleLabel?.text = nil
        subtitleLabel?.text = nil
        // STEP 2: load new info from user (if any)
        if let coreUser = self.coreUser {
            titleLabel.text = coreUser.username
            subtitleLabel.text = coreUser.bio
            if let avatar = UIImage(named: coreUser.profile_image!) {
                // profile_image cannot be nil
                avatarImageView.image = avatar
            } else {
                // just in case, Cat!
                avatarImageView.image = UIImage(named: "Cat")!
            }
        }
    }
    
    private func setupViews() {
        // tableViewCell
        backgroundColor = UIColor.clear
        // dividerView
        dividerView.backgroundColor = UIColor.midNightBlack()
        // contentView
        contentView.backgroundColor = UIColor.mediumBlueGray()
        // avatarImageView
        avatarImageView.layer.cornerRadius = 32
        avatarImageView.layer.borderColor = UIColor.white.cgColor
        avatarImageView.layer.borderWidth = 2
        avatarImageView.image = UIImage(named: "Cat")
        // titleLabel
        titleLabel.textColor = UIColor.white
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.text = "username"
        // subtitleLabel
        subtitleLabel.textColor = UIColor.candyWhite()
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.text = "bio"
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if highlighted == true {
            contentView.backgroundColor = UIColor.miamiBlue()
            
        } else {
            contentView.backgroundColor = UIColor.mediumBlueGray()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
}


























