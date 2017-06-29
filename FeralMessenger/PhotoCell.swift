//
//  PhotoCell.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/2/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit


class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    static let id = "PhotoCell"
    
    var avatar: Avatar? {
        didSet {
            updateCell()
        }
    }
    
    private func updateCell() {
        // STEP 1: reset any existing UI info/outlets
        avatarImageView?.image = nil
        // STEP 2: load new info from user (if any)
        if let avatar = self.avatar, let image = UIImage(named: avatar.name) {
            avatarImageView.image = image
        }
    }
    
    private func setupViews() {
        // collectionViewCell
        backgroundColor = UIColor.clear
        // wrapperView
        wrapperView.backgroundColor = UIColor.clear
        // profileImage
        avatarImageView.layer.borderColor = UIColor.white.cgColor
        avatarImageView.layer.borderWidth = 2
    }
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? UIColor.orange : UIColor.clear
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
}
