//
//  HomeViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/20/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import Parse
import AVFoundation


class MasterViewController: UITableViewController {
    
    // MARK: - UI
    
    lazy var titleButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor.white
        button.setTitle("Chats", for: UIControlState.normal)
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 21)
        return button
    }()
    
    func beginRefresh() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.refreshControl?.beginRefreshing()
        }
        tableView.refreshControl?.layoutIfNeeded()
    }
    
    func endRefresh() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.refreshControl?.endRefreshing()
        }
    }
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        beginRefresh()
        manager?.readUsersInParse(with: nil, completion: { [weak self] (users: [PFObject]?) in
            if let users = users {
                self?.parseUsers = users
                self?.endRefresh()
            }
        })
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
        tableView.refreshControl?.tintColor = UIColor.candyWhite()
    }
    
    // MARK: - Lifecycle
    
    var parseUsers = [PFObject]()
    
    var manager: ParseManager?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationController()
        beginRefresh()
        manager = ParseManager()
        manager?.readUsersInParse(with: nil, completion: { [weak self] (users: [PFObject]?) in
            guard let users = users else { return }
            self?.parseUsers = users
            self?.endRefresh()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTabBar()
    }
    
}























