//
//  AddFriendViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 7/3/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit


class AddFriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - NavigationController
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBAction func cancelButton_tapped(_ sender: UIBarButtonItem) {
        dismissAddFriendViewController()
    }
    
    private func setupNavigationController() {
        guard let navigationController = navigationController else { return }
        navigationItem.rightBarButtonItem?.tintColor = UIColor.orange
        navigationController.navigationBar.backgroundColor = UIColor.mediumBlueGray
        navigationController.navigationBar.tintColor = UIColor.mediumBlueGray
    }
    
    // MARK: - UISearchBar
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    private func setupSearchBar() {
        searchBar.backgroundColor = UIColor.candyWhite
        searchBar.tintColor = UIColor.mediumBlueGray
    }
    
    // MARK: - UITableView
    
    @IBOutlet weak var tableView: UITableView!
    
    private func setupTableView() {
        self.view.backgroundColor = UIColor.midNightBlack
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.midNightBlack
    }
    
    // MARK: - Lifecycle
    
    func dismissAddFriendViewController() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupSearchBar()
        setupNavigationController()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultCell.id, for: indexPath) as? SearchResultCell else {
            return UITableViewCell()
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
}

























