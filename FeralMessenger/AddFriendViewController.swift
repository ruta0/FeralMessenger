//
//  AddFriendViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 7/3/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit


class AddFriendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    // MARK: - NavigationController
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBAction func cancelButton_tapped(_ sender: UIBarButtonItem) {
        dismissAddFriendViewController()
    }

    lazy var titleButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor.white
        button.setTitle("Add Friend", for: UIControlState.normal)
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 25)
        return button
    }()

    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        view.hidesWhenStopped = true
        return view
    }()

    func beginLoadingAnime() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            self.navigationItem.titleView = self.activityIndicator
        }
    }

    func endLoadingAnime() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.navigationItem.titleView = self.titleButton
        }
    }

    var timer: Timer?

    func scheduleNavigationPrompt(with message: String, duration: TimeInterval) {
        DispatchQueue.main.async {
            self.navigationItem.prompt = message
            self.timer = Timer.scheduledTimer(timeInterval: duration,
                                              target: self,
                                              selector: #selector(self.removePrompt),
                                              userInfo: nil,
                                              repeats: false)
            self.timer?.tolerance = 5
        }
    }

    @objc private func removePrompt() {
        if navigationItem.prompt != nil {
            DispatchQueue.main.async {
                self.navigationItem.prompt = nil
            }
        }
    }

    // The colour of the rightBarButton doesn't feel like changing.
    // Create the rightBarButton programmatically
    private func setupNavigationController() {
        guard let navigationController = navigationController else { return }
        navigationItem.titleView = titleButton
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.barTintColor = UIColor.mediumBlueGray
    }
    
    // MARK: - UISearchBar

    let searchController = UISearchController(searchResultsController: nil)

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        search(searchText: searchText)
    }

    func search(searchText: String) {
        // override this to implement
    }

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.barStyle = UIBarStyle.default
        searchController.searchBar.placeholder = "Search by email"
        searchController.searchBar.barTintColor = UIColor.mediumBlueGray
        let cancelButtonAttributes: [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.candyWhite]
        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes as [String : AnyObject], for: UIControlState.normal)
        searchController.searchBar.keyboardAppearance = UIKeyboardAppearance.dark
        tableView.tableHeaderView = searchController.searchBar
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
        setupSearchController()
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

























