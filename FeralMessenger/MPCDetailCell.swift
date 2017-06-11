//
//  MPCDetailCell.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/7/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit


class MPCDetailCell: UITableViewCell {
    
    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var smsTextView: UITextView!
    
    var mpcMessage: CoreMessage? {
        didSet {
            updateCell()
        }
    }
    
    private func updateCell() {
        usernameLabel?.text = nil
        usernameLabel?.text = nil
        if let mpcMessage = self.mpcMessage {
            usernameLabel.text = mpcMessage.sender_name
            smsTextView.text = mpcMessage.sms
        }
    }
    
    private func setupViews() {
        // cell
        backgroundColor = UIColor.clear
        // wrapperView
        wrapperView.backgroundColor = UIColor.clear
        // usernameLabel
        usernameLabel.textColor = UIColor.lightGray
        usernameLabel.backgroundColor = UIColor.clear
        // smsLabel
        smsTextView.textColor = UIColor.white
        smsTextView.backgroundColor = UIColor.clear
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
}
