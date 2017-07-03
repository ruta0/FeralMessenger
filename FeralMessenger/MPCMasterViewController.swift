//
//  MPCViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/4/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import AudioToolbox


class MPCMasterViewController: UITableViewController {
    
    func vibrate() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    func presentInvigation(fromPeer: String, group: String) {
        let alert = UIAlertController(title: "\(group) wants to chat with you", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let accept = UIAlertAction(title: "Accept", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            self.acceptInvitation()
        }
        let decline = UIAlertAction(title: "Decline", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            self.declineInvitation()
        }
        alert.addAction(accept)
        alert.addAction(decline)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func acceptInvitation() {
        // override this to implement
    }
    
    func declineInvitation() {
        // override this to implement
    }
    
    // MARK: - RadioHeaderView
    
    @IBOutlet weak var radioHeaderView: RadioHeaderView!
    
    func radioSwitch_tapped(_ sender: UISwitch) {
        // override this to implement
    }
    
    private func setupRadioHeaderView() {
        radioHeaderView.radioSwitch.addTarget(self, action: #selector(self.radioSwitch_tapped(_:)), for: UIControlEvents.touchUpInside)
        radioHeaderView.titleLabel.text = "Proximity Radio"
        radioHeaderView.radioSwitch.isOn = false
    }
    
    // MARK: - UITableView
    
    func tableViewReloadData() {
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }
    
    private func setupViews() {
        tableView.contentInset = UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = UIColor.midNightBlack()
    }
    
    // MARK: - TabBarController
    
    private func setupTabBar() {
        guard let tabBar = tabBarController?.tabBar else { return }
        tabBar.tintColor = UIColor.candyWhite()
        tabBar.barTintColor = UIColor.midNightBlack()
        tabBar.isHidden = false
        tabBar.isTranslucent = false
    }
    
    // MARK: - NavigationController
    
    lazy var titleButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor.white
        button.setTitle("Proximity", for: UIControlState.normal)
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 25)
        return button
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        view.hidesWhenStopped = true
        return view
    }()
    
    func addNavigationPrompt(message: String) {
        navigationItem.prompt = message
    }
    
    func removeNavigationPrompt() {
        navigationItem.prompt = nil
    }
    
    func beginLoadingAnime(message: String) {
        DispatchQueue.main.async {
            self.navigationItem.titleView = self.activityIndicator
            self.activityIndicator.startAnimating()
        }
    }
    
    func stopLoadingAnime() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.navigationItem.titleView = self.titleButton
        }
    }

    private func setupNavigationController() {
        guard let navigationController = navigationController else { return }
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.barTintColor = UIColor.mediumBlueGray()
        navigationController.navigationBar.tintColor = UIColor.white
        navigationItem.titleView = titleButton
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.orange]
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationController()
        setupRadioHeaderView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTabBar()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }

}















