//
//  MPCMessageViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 7/2/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import MultipeerConnectivity


class MPCMessageViewController: MPCDetailViewContrller {
    
    // MARK: - Lifecycle
    
    private func popViewController() {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messagesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MPCDetailCell.id, for: indexPath) as! MPCDetailCell
        let message = messagesArray[indexPath.row] as Dictionary<String, String>
        if let sender = message["sender"] {
            cell.usernameLabel.text = sender
        }
        if let sms = message["message"] {
            cell.smsTextView.text = sms
        }
        return cell
    }
    
}
