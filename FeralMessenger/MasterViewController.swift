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
class MasterViewController: FetchedResultsViewController {
    
    fileprivate var users = [Array<User>]()
    
    private var lastQuery: String? // query itself might change if the user becomes impatient and immediately decides to query with a different keyword
    
    var searchText: String? {
        didSet {
            users.removeAll()
            collectionView?.reloadData()
            searchForUsers()
            title = searchText
        }
    }
    
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
        button.setTitle("Chats", for: UIControlState.normal)
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 21)
        return button
    }()

    func searchForUsers() {
        if let query = searchText, !query.isEmpty {
            lastQuery = query
            let predicate = NSPredicate(format: "username = %@", searchText!)
            readUserInParse(with: predicate, completion: { [weak self] (pfObjects: [PFObject]?) in
                DispatchQueue.main.async {
                    if query == self?.lastQuery {
                        print(pfObjects!)
                        // insert into the collectionView starting from the top
                        self?.users.insert(pfObjects as! [User], at: 0)
                        self?.collectionView?.insertSections([0])
                    }
                }
            })
        }
    }
    
    func reloadColectionView() {
        DispatchQueue.main.async { [weak self] in
            self?.collectionView?.reloadData()
        }
    }
    
    func handleRefresh() {
        refreshController.beginRefreshing()
        DispatchQueue.main.async { [weak self] in
            self?.collectionView?.reloadData()
            self?.refreshController.endRefreshing()
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
        navigationItem.titleView = titleButton
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
        setupNavigationController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTabBar()
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
        let edgeInset = UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
        return edgeInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 84)
    }
    
}


// MARK: - Parse

extension MasterViewController {
    
    func readUserInParse(with predicate: NSPredicate?, completion: @escaping ([PFObject]?) -> Void) {
        guard let predicate = predicate, let query = User.query(with: predicate) else { return }
        query.findObjectsInBackground { (users: [PFObject]?, error: Error?) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                completion(users)
            }
        }
    }
    
    func readUserInParse(completion: @escaping ([PFObject]) -> Void) {
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























