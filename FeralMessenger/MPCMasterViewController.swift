//
//  MPCViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/4/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import AudioToolbox


class MPCMasterViewController: UITableViewController {
    
    // MARK: - RadarView
    
    @IBOutlet weak var radarView: UIView!
    @IBOutlet weak var radarImageView: UIImageView!
    @IBOutlet weak var radarLabel: UILabel!
    @IBOutlet weak var radarSwitch: UISwitch!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBAction func radarSwitch_tapped(_ sender: UISwitch) {
        if sender.isOn {
            sender.setOn(false, animated: true)
            appDelegate.mpcManager.stopAdvertise()
        } else {
            sender.setOn(true, animated: true)
            appDelegate.mpcManager.startAdvertise()
        }
    }
    
    // MARK: - UITableView
    
    func tableViewReloadData() {
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }
    
    private func setupViews() {
        // tableView
        tableView.contentInset = UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = UIColor.midNightBlack()
        // radarView
        radarView.backgroundColor = UIColor.mediumBlueGray()
        // radarImageView
        let originalImage = UIImage(named: "Radar")
        let tintedImage = originalImage?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        radarImageView.image = tintedImage
        radarImageView.tintColor = UIColor.white
        radarImageView.contentMode = UIViewContentMode.scaleAspectFill
        // radarLabel
        radarLabel.backgroundColor = UIColor.clear
        radarLabel.textColor = UIColor.white
        // radarSwitch
        radarSwitch.isOn = false
        radarSwitch.tintColor = UIColor.mandarinOrange()
        radarSwitch.onTintColor = UIColor.orange
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
    
    private let mpcChatViewControllerSegue = "SegueToMPCMessageViewController"
    
    private func showMPCChatsViewController() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: self.mpcChatViewControllerSegue, sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationController()
        setupMPCManagerDelegate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appDelegate.mpcManager.serviceBrowser.startBrowsingForPeers()
        setupTabBar()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        appDelegate.mpcManager.serviceBrowser.stopBrowsingForPeers()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // implement this
    }
    
    // MARK: - UITableViewDataSource
        
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.mpcManager.foundPeers.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPeer = appDelegate.mpcManager.foundPeers[indexPath.row]
        appDelegate.mpcManager.serviceBrowser.invitePeer(selectedPeer, to: appDelegate.mpcManager.session, withContext: nil, timeout: 20)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MPCMasterCell.id, for: indexPath) as! MPCMasterCell
        // implement this
        cell.groupLabel.text = appDelegate.mpcManager.foundPeers[indexPath.row].displayName
        let numberOfPeers = appDelegate.mpcManager.foundPeers.count
        cell.countLabel.text = String(describing: numberOfPeers)
        cell.titleLabel.text = "hello world"
        return cell
    }

}


// MARK: - MPCManagerDelegate

extension MPCMasterViewController: MPCManagerDelegate {
    
    func setupMPCManagerDelegate() {
        appDelegate.mpcManager.delegate = self
    }
    
    func didStartAdvertising() {
        addNavigationPrompt(message: "Broadcasting")
    }
    
    func didStopAdvertising() {
        removeNavigationPrompt()
    }
    
    func foundPeer() {
        tableViewReloadData()
    }
    
    func lostPeer() {
        tableViewReloadData()
    }
    
    func didReceivedInvitation(fromPeer: String, group: String) {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        let alert = UIAlertController(title: "\(group) wants to chat with you", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        let accept = UIAlertAction(title: "Accept", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            self.appDelegate.mpcManager.invitationHandler(true, self.appDelegate.mpcManager.session)
        }
        let decline = UIAlertAction(title: "Decline", style: UIAlertActionStyle.default) { (action: UIAlertAction) in
            self.appDelegate.mpcManager.invitationHandler(false, nil)
        }
        alert.addAction(accept)
        alert.addAction(decline)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func didConnect(fromPeer: MCPeerID, group: String) {
        // perform some cool anime as well
    }
    
}














