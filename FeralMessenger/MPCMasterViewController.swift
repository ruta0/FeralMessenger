//
//  MPCViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/4/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import Parse
import CoreData
import MultipeerConnectivity


// MARK: - UI

class MPCMasterViewController: UITableViewController {
    
    fileprivate let cellID = "MPCGroupCell"
    fileprivate let headerID = "MPCGroupViewHeader" // could add group count
    fileprivate let mpcChatViewControllerSegue = "MPCMessageViewControllerSegue"
    
    @IBOutlet weak var radarView: UIView!
    @IBOutlet weak var radarImageView: UIImageView!
    @IBOutlet weak var radarLabel: UILabel!
    @IBOutlet weak var radarSwitch: UISwitch!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    lazy var fetchedResultsController: NSFetchedResultsController<CoreUser> = {
        let frc = NSFetchedResultsController(fetchRequest: CoreUser.defaultFetchRequest(with: nil), managedObjectContext: CoreDataManager.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()

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
    
    @IBAction func radarSwitch_tapped(_ sender: UISwitch) {
        if sender.isOn {
            sender.setOn(false, animated: true)
            appDelegate.mpcManager.serviceAdvertiser.stopAdvertisingPeer()
            print("it's off")
        } else {
            sender.setOn(true, animated: true)
            appDelegate.mpcManager.serviceAdvertiser.startAdvertisingPeer()
            print("it's on")
        }
    }
    
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
    
    fileprivate func setupMPCManager() {
        appDelegate.mpcManager.delegate = self
        appDelegate.mpcManager.serviceBrowser.startBrowsingForPeers()
    }
    
    fileprivate func setupNavigationController() {
        guard let navigationController = navigationController else { return }
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.barTintColor = UIColor.mediumBlueGray()
        navigationController.navigationBar.tintColor = UIColor.white
        navigationItem.titleView = titleButton
    }
    
    fileprivate func setupViews() {
        // tableView
        tableView.contentInset = UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.backgroundColor = UIColor.midNightBlack()
        tableView.addSubview(refreshController)
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
        radarSwitch.tintColor = UIColor.miamiBlue()
        radarSwitch.onTintColor = UIColor.miamiBlue()
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

extension MPCMasterViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationController()
        setupMPCManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTabBar()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // implement this
    }
    
}


// MARK: - UITableViewDataSource

extension MPCMasterViewController {
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! MPCMasterCell
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
    
    func startAdvertising() {
        appDelegate.mpcManager.serviceAdvertiser.startAdvertisingPeer()
        // implement some cool animation
    }
    
    func stopAdvertising() {
        appDelegate.mpcManager.serviceAdvertiser.stopAdvertisingPeer()
        // implement some cool animation
    }
    
    func foundPeer() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func lostPeer() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func didReceivedInvitation(fromPeer: String, group: String) {
        let alert = UIAlertController(title: "", message: "\(group) wants to chat with you", preferredStyle: UIAlertControllerStyle.alert)
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
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: self.mpcChatViewControllerSegue, sender: self)
            // perform some cool anime as well
        }
    }
    
}


// MARK: - NSFetchedResultsControllerDelegate

extension MPCMasterViewController: NSFetchedResultsControllerDelegate {
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: tableView.insertSections([sectionIndex], with: .fade)
        case .delete: tableView.deleteSections([sectionIndex], with: .fade)
        default: break
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
}















