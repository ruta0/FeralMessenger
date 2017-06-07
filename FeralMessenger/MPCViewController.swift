//
//  NotificationsViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/4/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import Parse


// MARK: - UI

class MPCViewController: UITableViewController {
    
    fileprivate let cellID = "MPCCell"
    fileprivate let headerID = "MPCViewHeader" // could add group count
    
    var mpcManager: MPCManager!

    lazy var refreshController: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = UIColor.candyWhite()
        control.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
        return control
    }()
    
    lazy var titleButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor.white
        button.setTitle("Proximity", for: UIControlState.normal)
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 21)
        return button
    }()
    
    func handleRefresh() {
        refreshController.beginRefreshing()
        DispatchQueue.main.async { [weak self] in
            self?.tableView?.reloadData()
            self?.refreshController.endRefreshing()
        }
    }
    
    func reloadColectionView() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView?.reloadData()
        }
    }
    
    fileprivate func setupNavigationController() {
        guard let navigationController = navigationController else { return }
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.barTintColor = UIColor.mediumBlueGray()
        navigationController.navigationBar.tintColor = UIColor.white
        navigationItem.titleView = titleButton
    }
    
    fileprivate func setupTableView() {
        tableView.backgroundColor = UIColor.midNightBlack()
        tableView.addSubview(refreshController)
    }
    
    fileprivate func setupTabBar() {
        guard let tabBar = tabBarController?.tabBar else { return }
        tabBar.tintColor = UIColor.candyWhite()
        tabBar.barTintColor = UIColor.midNightBlack()
        tabBar.isHidden = false
        tabBar.isTranslucent = false
    }

}


// MARK: - Lifecycle

extension MPCViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationController()
        mpcManager = MPCManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTabBar()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // implement this
    }
    
}


// MARK: - UITableViewLayout

extension MPCViewController {
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
}


// MARK: - UITableViewDataSource

extension MPCViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! MPCCell
        return cell
    }
    
}






















