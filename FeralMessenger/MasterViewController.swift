//
//  HomeViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/20/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit


class MasterViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - NavigationController
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        view.hidesWhenStopped = true
        return view
    }()
    
    lazy var titleButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor.white
        button.setTitle("Chats", for: UIControlState.normal)
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 25)
        return button
    }()
    
    @IBAction func addButton_tapped(_ sender: UIBarButtonItem) {
        print(123)
    }
    
    func beginLoadingAnime() {
        DispatchQueue.main.async {
            self.navigationItem.titleView = self.activityIndicator
            self.activityIndicator.startAnimating()
        }
    }
    
    func endLoadingAnime() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.navigationItem.titleView = self.titleButton
        }
    }
    
    private func setupNavigationController() {
        guard let navigationController = navigationController else {
            print("navigationController cannot be nil")
            return
        }
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.barTintColor = UIColor.mediumBlueGray()
        navigationController.navigationBar.tintColor = UIColor.white
        addButton.tintColor = UIColor.orange
    }
    
    // MARK: - TabBarController
    
    private func setupTabBar() {
        guard let tabBar = tabBarController?.tabBar else {
            print("tabBarController cannot be nil")
            return
        }
        tabBar.tintColor = UIColor.candyWhite()
        tabBar.barTintColor = UIColor.midNightBlack()
        tabBar.isHidden = false
        tabBar.isTranslucent = false
    }
    
    // MARK: - UITableView
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableViewReload() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    private func setupTableView() {
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = UIColor.midNightBlack()
        tableView.refreshControl?.tintColor = UIColor.candyWhite()
    }
    
    // MARK: - Lifecycle
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTabBar()
    }
    
    // MARK: - UITableViewDelegate
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let masterCell = tableView.dequeueReusableCell(withIdentifier: MasterCell.id, for: indexPath) as? MasterCell else {
            return UITableViewCell()
        }
        return masterCell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
}
























