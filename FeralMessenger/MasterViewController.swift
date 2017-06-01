//
//  HomeViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/20/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import Parse


// MARK: - UI

// This is a generic masterViewController designed to be subclassed to complete its functionality with either Core Data or Realm
class MasterViewController: FetchedResultsCollectionViewController {
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    lazy var refreshController: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = UIColor.candyWhite()
        control.addTarget(self, action: #selector(handleRefresh), for: UIControlEvents.valueChanged)
        return control
    }()
    
    lazy var titleButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor.white
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 21)
        return button
    }()
    
    @IBAction func logoutButton_tapped(_ sender: UIBarButtonItem) {
        performLogout()
    }
    
    func handleFatalErrorResponse(fatalError: Error) {
        let alert = UIAlertController(title: "Unexpected Error", message: fatalError.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func reloadColectionView() {
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    func handleRefresh() {
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
            self.refreshController.endRefreshing()
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
        // setting the title of the navigationItem
        guard let username = PFUser.current()?.username else {
            print("setupNavigationController - PFUser.current()?.username is nil")
            return
        }
        titleButton.setTitle(username, for: UIControlState.normal)
    }
    
    fileprivate func setupCollectionView() {
        guard let collectionView = collectionView else { return }
        collectionView.backgroundColor = UIColor.midNightBlack()
        collectionView.addSubview(refreshController)
    }
    
}


// MARK: - Lifecycle

extension MasterViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupTabBar()
        setupNavigationController()
    }
    
}


// MARK: - UICollectionViewDelegateFlowLayout

extension MasterViewController: UICollectionViewDelegateFlowLayout {
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let edgeInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return edgeInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 84)
    }
    
}


// MARK: - Keychain

extension MasterViewController {
    
    func removeTokenFromKeychain() {
        let item = KeychainItem(service: KeychainConfiguration.serviceName, account: "auth_token", accessGroup: KeychainConfiguration.accessGroup)
        do {
            try item.deleteItem()
        } catch let err {
            print(err)
        }
    }
    
}


// MARK: - Parse

extension MasterViewController {
    
    func performLogout() {
        PFUser.logOutInBackground { [weak self] (error: Error?) in
            self?.removeTokenFromKeychain()
            if error != nil {
                self?.handleFatalErrorResponse(fatalError: error!)
            } else {
                self?.tabBarController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func downloadUserFromParse(completion: @escaping ([PFObject]) -> Void) {
        guard let query = User.query() else { return }
        query.findObjectsInBackground { ( pfObjects: [PFObject]?, error: Error?) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                guard let pfObjects = pfObjects else {
                    print("updateCoreUserFromParse - pfObjects are nil")
                    return
                }
                completion(pfObjects)
            }
        }
    }
    
}























