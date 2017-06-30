//
//  DisclosureViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/2/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import Parse


class DisclosureViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - NavigationController
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        view.hidesWhenStopped = true
        return view
    }()
    
    lazy var titleButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor.white
        button.setTitle("Avatar", for: UIControlState.normal)
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 25)
        return button
    }()
    
    @IBAction func saveButton_tapped(_ sender: UIBarButtonItem) {
        if selectedAvatarName != nil {
            updateAvatarInParse(with: selectedAvatarName!)
        }
    }
    
    func beginLoadingAnime() {
        DispatchQueue.main.async {
            self.navigationItem.titleView = self.activityIndicator
            self.activityIndicator.startAnimating()
        }
    }
    
    func endLoadingAnime() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.navigationItem.titleView = self.titleButton
        }
    }
    
    private func setupNavigationController() {
        navigationItem.titleView = titleButton
        navigationItem.backBarButtonItem?.tintColor = UIColor.orange
        saveButton.tintColor = UIColor.orange
    }
    
    // MARK: - TabBarController
    
    private func setupTabBar() {
        guard let tabBar = tabBarController?.tabBar else { return }
        tabBar.isHidden = true
    }
    
    // MARK: - UICollectionView
    
    var avatars: [Avatar]?
    var selectedAvatarName: String?
    
    private func setupCollectionView() {
        guard let collectionView = collectionView else { return }
        collectionView.backgroundColor = UIColor.midNightBlack()
    }
    
    var fileName: String = {
        if isSudoGranted == true {
            return "SpecialAvatars"
        } else {
            return "Avatars"
        }
    }()
    
    private func fetchAvatarsFromPropertyList(for resource: String, of type: String) {
        var items = [Avatar]()
        guard let inputFile = Bundle.main.path(forResource: resource, ofType: type) else {
            print("DisclosureViewController: - Undefined property list")
            return
        }
        let inputArray = NSArray(contentsOfFile: inputFile)
        for inputItem in inputArray as! [Dictionary<String, String>] {
            let imageNameItem = Avatar(nameDictionary: inputItem)
            items.append(imageNameItem)
        }
        self.avatars = items
    }
    
    // MARK: - Lifecycle
    
    private func popViewController() {
        if let nav = self.navigationController {
            DispatchQueue.main.async {
                nav.popViewController(animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupNavigationController()
        setupCollectionView()
        fetchAvatarsFromPropertyList(for: fileName, of: "plist")
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let edgeInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return edgeInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width/3, height: view.frame.width/3)
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedAvatarName = avatars?[indexPath.item].name
        DispatchQueue.main.async {
            self.saveButton.tintColor = UIColor.orange
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return avatars?.count ?? 0
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as? PhotoCell else {
            fatalError("failed to dequeue photoCell")
        }
        if let avatar = avatars?[indexPath.item] {
            cell.avatar = avatar
        }
        return cell
    }
    
    // MARK: - Parse
    
    var currentUser: PFUser {
        let user = PFUser.current()!
        return user
    }
    
    func updateAvatarInParse(with newAvatarName: String) {
        currentUser["avatar"] = newAvatarName
        activityIndicator.startAnimating()
        currentUser.saveInBackground { [unowned self] (completed: Bool, error: Error?) in
            self.activityIndicator.stopAnimating()
            if error != nil {
                print("updateAvatarInParse - failed to update avatar name To Parse")
                return
            } else {
                if completed == true {
                    print("updateAvatarInParse - successfully saved to Parse")
                    self.popViewController()
                }
            }
        }
    }
    
}













