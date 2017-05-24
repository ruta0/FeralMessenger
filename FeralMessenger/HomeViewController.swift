//
//  HomeViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/20/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import Parse


class HomeViewController: UICollectionViewController {
    
    fileprivate let cellID = "HomeCell"
    
    var users = [User]()
    var selectedUser = User()
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    @IBAction func logoutButton_tapped(_ sender: UIBarButtonItem) {
        performLogout()
    }
    
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
    }
    
    private func setupViews() {
        guard let collectionView = collectionView else { return }
        collectionView.backgroundColor = UIColor.midNightBlack()
        collectionView.addSubview(refreshController)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchUsers()
        // huh, wrong place to set the nav title, but yolo...
        titleButton.setTitle(PFUser.current()?.username!, for: UIControlState.normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setupTabBar()
        setupNavigationController()
    }
    
}


// MARK: - UICollectionViewDelegateFlowLayout

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    
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


// MARK: - UICollectionViewDelegate

extension HomeViewController {
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! HomeCell
        cell.usernameLabel.text = users[indexPath.item].username
        cell.messageLabel.text = users[indexPath.item].timezone
        return cell
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
}





























