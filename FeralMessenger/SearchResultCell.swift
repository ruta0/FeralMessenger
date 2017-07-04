//
//  SearchResultCell.swift
//  FeralMessenger
//
//  Created by rightmeow on 7/3/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit


class SearchResultCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    @IBAction func addButton_tapped(_ sender: UIButton) {
        // notify the controller
    }
    
    static let id = "SearchResultCell"
    
    private func setupViews() {
        self.backgroundColor = UIColor.mediumBlueGray
        titleLabel.backgroundColor = UIColor.clear
        addButton.backgroundColor = UIColor.clear
    }
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
}
