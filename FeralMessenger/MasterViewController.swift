//
//  HomeViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/20/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import Parse
import CoreData


private let cellID = "MasterCell"

class MasterViewController: FetchedResultsCollectionViewController {
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    var container: NSPersistentContainer? = CoreDataStack.persistentContainer
    
    lazy var fetchedResultsController: NSFetchedResultsController<CoreUser> = {
        let frc = NSFetchedResultsController(fetchRequest: CoreUser.defaultFetchedRequest, managedObjectContext: CoreDataStack.viewContext, sectionNameKeyPath: nil, cacheName: nil)
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
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 21)
        return button
    }()
    
    @IBAction func logoutButton_tapped(_ sender: UIBarButtonItem) {
        performLogout()
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
    
    private func setupTabBar() {
        guard let tabBar = tabBarController?.tabBar else { return }
        tabBar.tintColor = UIColor.candyWhite()
        tabBar.barTintColor = UIColor.midNightBlack()
        tabBar.isHidden = false
        tabBar.isTranslucent = false
    }
    
    private func setupNavigationController() {
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
    
    private func setupCollectionView() {
        guard let collectionView = collectionView else { return }
        collectionView.backgroundColor = UIColor.midNightBlack()
        collectionView.addSubview(refreshController)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        updateCoreUserFromParse()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupTabBar()
        setupNavigationController()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailViewControllerSegue" {
            guard let selectedCell = sender as? MasterCell else {
                print("unexpected sender of cell")
                return
            }
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.selectedUserName = selectedCell.usernameLabel.text!
            detailViewController.container = container
        }
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


// MARK: - UICollectionViewDataSource + NSFetchedResultsController

extension MasterViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = fetchedResultsController.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath)
        let coreUser = fetchedResultsController.object(at: indexPath)
        if let masterCell = cell as? MasterCell {
            masterCell.coreUser = coreUser
        }
        return cell
    }
    
}



























