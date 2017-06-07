//
//  NotificationCell.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/5/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit

class MPCCell: UITableViewCell {
    
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    fileprivate func setupViews() {
        // contentView
        self.contentView.backgroundColor = UIColor.clear
        // groupLabel
        groupLabel.backgroundColor = UIColor.clear
        // countLabel
        countLabel.backgroundColor = UIColor.clear
        // titleLabel
        titleLabel.backgroundColor = UIColor.clear
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
}
