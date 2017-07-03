//
//  RadioHeaderView.swift
//  FeralMessenger
//
//  Created by rightmeow on 7/2/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit


class RadioHeaderView: UIView {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var radioImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var radioSwitch: UISwitch!
    
    private func setupViews() {
        // view
        self.addSubview(view)
        view.frame = self.bounds
        view.backgroundColor = UIColor.mediumBlueGray()
        // radioImageView
        let originalImage = #imageLiteral(resourceName: "Radar")
        let tintedImage = originalImage.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        radioImageView.image = tintedImage
        radioImageView.tintColor = UIColor.white
        radioImageView.backgroundColor = UIColor.clear
        radioImageView.contentMode = UIViewContentMode.scaleAspectFill
        // titleLabel
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.white
        // radioSwitch
        radioSwitch.isOn = false
        radioSwitch.tintColor = UIColor.mandarinOrange()
        radioSwitch.onTintColor = UIColor.orange
    }
    
    // MARK: - Lifecycle
    
    private let nibName = "RadioHeaderView"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        UINib(nibName: nibName, bundle: nil).instantiate(withOwner: self, options: nil)
        setupViews()
    }
    
}
