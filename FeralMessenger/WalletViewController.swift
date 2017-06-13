//
//  WalletViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/12/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit


class WalletViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var titleButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor.white
        button.setTitle("Wallet", for: UIControlState.normal)
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 21)
        return button
    }()
    
    func beginRefresh() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.refreshControl?.beginRefreshing()
        }
    }
    
    func endRefresh() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.refreshControl?.endRefreshing()
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
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        navigationItem.titleView = titleButton
    }
    
    fileprivate func setupTableView() {
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = UIColor.midNightBlack()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        tableView.invalidateIntrinsicContentSize()
    }
    
}


// MARK: - Lifecycle

extension WalletViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        setupTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupTabBar()
    }
    
}





























