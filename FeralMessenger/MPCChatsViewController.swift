//
//  MPCChatsViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 7/2/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import MultipeerConnectivity


class MPCChatsViewController: MPCMasterViewController, MPCManagerDelegate {
    
    // MARK: - Lifecycle
    
    private func showMPCChatsViewController() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: self.mpcChatViewControllerSegue, sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMPCManager()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appDelegate.mpcManager.serviceBrowser.startBrowsingForPeers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        appDelegate.mpcManager.serviceBrowser.stopBrowsingForPeers()
    }
    
    private let mpcChatViewControllerSegue = "SegueToMPCMessageViewController"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // implement this
    }
    
    // MARK: - MPCManagerDelegate
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    func setupMPCManager() {
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
        presentInvigation(fromPeer: fromPeer, group: group)
    }
    
    func didConnect(fromPeer: MCPeerID, group: String) {
        // perform some cool anime as well
    }
    
    override func acceptInvitation() {
        self.appDelegate.mpcManager.invitationHandler(true, self.appDelegate.mpcManager.session)
    }
    
    override func declineInvitation() {
        self.appDelegate.mpcManager.invitationHandler(false, nil)
    }
    
    override func radioSwitch_tapped(_ sender: UISwitch) {
        if sender.isOn {
            appDelegate.mpcManager.startAdvertise()
        } else {
            appDelegate.mpcManager.stopAdvertise()
        }
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
        appDelegate.mpcManager.serviceBrowser.invitePeer(selectedPeer, to: appDelegate.mpcManager.session!, withContext: nil, timeout: 20)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MPCMasterCell.id, for: indexPath) as! MPCMasterCell
        // implement this
        cell.groupLabel.text = appDelegate.mpcManager.foundPeers[indexPath.row].displayName
        let numberOfPeers = appDelegate.mpcManager.foundPeers.count
        cell.countLabel.text = String(describing: numberOfPeers)
        return cell
    }
    
    
}
