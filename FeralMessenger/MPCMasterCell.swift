//
//  NotificationCell.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/5/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit

class MPCMasterCell: UITableViewCell {
    
    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var mpcGroup: MPCGroup? {
        didSet {
            updateCell()
        }
    }
    
    private func updateCell() {
        
    }
    
    fileprivate func setupViews() {
        // cell
        self.backgroundColor = UIColor.clear
        // contentView
        self.contentView.backgroundColor = UIColor.clear
        // wrapperView
        wrapperView.backgroundColor = UIColor.mediumBlueGray()
        // groupLabel
        groupLabel.backgroundColor = UIColor.clear
        groupLabel.textColor = UIColor.white
        // countLabel
        countLabel.backgroundColor = UIColor.clear
        countLabel.textColor = UIColor.candyWhite()
        // titleLabel
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.candyWhite()
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

































