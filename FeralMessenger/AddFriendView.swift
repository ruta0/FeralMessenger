//
//  AddFriendView.swift
//  FeralMessenger
//
//  Created by rightmeow on 7/6/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit


class AddFriendView: UIView {

    @IBOutlet var view: UIView!
    @IBOutlet var userTextField: UITextField!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var addButton: UIButton!

    private func setupViews() {
        // view
        self.addSubview(view)
        view.frame = self.bounds
        view.backgroundColor = UIColor.mediumBlueGray
        // userTextField
        userTextField.backgroundColor = UIColor.black
        userTextField.textColor = UIColor.white
        // subtitleLabel
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.textColor = UIColor.white
        // addButton
        addButton.backgroundColor = UIColor.miamiBlue
    }

    // MARK: - Lifecycle

    private let nibName = "AddFriendView"

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UINib(nibName: nibName, bundle: nil).instantiate(withOwner: self, options: nil)
        setupViews()
    }

}
