//
//  NotificationsViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/12/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit


class NotificationsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var titleButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor.white
        button.setTitle("Notifications", for: UIControlState.normal)
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 21)
        return button
    }()
    
    func beginRefresh() {
        DispatchQueue.main.async {
            self.tableView.refreshControl?.beginRefreshing()
        }
    }
    
    func endRefresh() {
        DispatchQueue.main.async {
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    fileprivate func setupTabBar() {
        guard let tabBar = tabBarController?.tabBar else { return }
        tabBar.tintColor = UIColor.candyWhite()
        tabBar.barTintColor = UIColor.midNightBlack()
        tabBar.isHidden = false
        tabBar.isTranslucent = false
    }
    
    fileprivate func setupNavigationController() {
        guard let navigationController = navigationController else { return }
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.barTintColor = UIColor.mediumBlueGray()
        navigationController.navigationBar.tintColor = UIColor.white
        navigationItem.titleView = titleButton
    }
    
    fileprivate func setupTableView() {
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = UIColor.midNightBlack()
    }
    
}


// MARK: - Lifecycle

extension NotificationsViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupTableView()
        setupNavigationController()
    }
    
}


























