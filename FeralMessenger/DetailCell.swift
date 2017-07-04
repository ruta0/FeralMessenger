//
//  DetailCell.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/20/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit


class DetailCell: UITableViewCell {
    
    @IBOutlet weak var wrapperView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    
    static let id = "DetailCell"
    
    var coreMessage: CoreMessage? {
        didSet {
            updateCell()
        }
    }
    
    private func updateCell() {
        // STEP 1: reset any existing UI info/outlets, otherwise info will become misplaced
        messageTextView?.text = nil
        // STEP 2: load new info from user (if any)
        if let coreMessage = self.coreMessage {
            messageTextView.text = coreMessage.sms
        }
    }
    
    private func setupViews() {
        // collectionViewCell
        backgroundColor = UIColor.clear
        // wrapperView
        wrapperView.backgroundColor = UIColor.clear
        // messageTextView
        messageTextView.textColor = UIColor.white // deafult
        messageTextView.backgroundColor = UIColor.miamiBlue // default
        messageTextView.font = UIFont.systemFont(ofSize: 14)
        messageTextView.layer.cornerRadius = 10
        messageTextView.textContainerInset.left = 3
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
}





















