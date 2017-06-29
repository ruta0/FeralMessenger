//
//  InputContainerView.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/28/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit


class InputContainerView: UIView {
    
    private let nibName = "InputContainerView"
    
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    func setupViews() {
        contentView.frame = self.bounds
        contentView.backgroundColor = UIColor.midNightBlack()
        dividerView.backgroundColor = UIColor.mediumBlueGray()
        inputTextField.backgroundColor = UIColor.clear
        inputTextField.attributedPlaceholder = NSAttributedString(string: "Message", attributes: [NSForegroundColorAttributeName: UIColor.darkGray])
        sendButton.backgroundColor = UIColor.clear
    }
    
    // MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UINib(nibName: nibName, bundle: nil).instantiate(withOwner: self, options: nil)
    }
    
}
