//
//  InputContainerView.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/28/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit


class InputContainerView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    private func setupViews() {
        // view
        self.addSubview(view)
        view.frame = self.bounds
        // contentView
        contentView.backgroundColor = UIColor.midNightBlack
        // dividerView
        dividerView.backgroundColor = UIColor.mediumBlueGray
        // inputTextFied
        inputTextField.backgroundColor = UIColor.clear
        inputTextField.textColor = UIColor.white
        inputTextField.attributedPlaceholder = NSAttributedString(string: "Enter message", attributes: [NSForegroundColorAttributeName: UIColor.darkGray])
        // sendButton
        sendButton.backgroundColor = UIColor.clear
        sendButton.tintColor = UIColor.white
    }
    
    // MARK: - Lifecycle
    
    private let nibName = "InputContainerView"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UINib(nibName: nibName, bundle: nil).instantiate(withOwner: self, options: nil)
        setupViews()
    }
    
}





















