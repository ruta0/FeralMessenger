//
//  DisclosureViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/2/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import Parse


class DisclosureViewController: UICollectionViewController {
    
    var avatars: [Avatar]?
    var selectedAvatarName: String?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBAction func saveButton_tapped(_ sender: UIBarButtonItem) {
        if selectedAvatarName != nil {
            updateAvatarInParse(with: selectedAvatarName!)
        }
    }
    
    fileprivate func fetchAvatarsFromPropertyList(for resource: String, of type: String) {
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
    
    fileprivate func setupCollectionView() {
        guard let collectionView = collectionView else { return }
        collectionView.backgroundColor = UIColor.midNightBlack()
    }
    
    fileprivate func setupTabBar() {
        guard let tabBar = tabBarController?.tabBar else { return }
        tabBar.isHidden = true
    }
    
}


// MARK: - Lifecycle

extension DisclosureViewController {
    
    fileprivate func popViewController() {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupCollectionView()
        fetchAvatarsFromPropertyList(for: "Avatars", of: "plist")
    }
    
}


// MARK: - UICollectionViewDelegateFlowLayout

extension DisclosureViewController: UICollectionViewDelegateFlowLayout {
    
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
    
}


// MARK: - UICollectionViewDataSource

extension DisclosureViewController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedAvatarName = avatars?[indexPath.item].name
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
    
}


// MARK: - Parse

extension DisclosureViewController {
    
    func updateAvatarInParse(with newAvatarName: String) {
        guard let currentUser = PFUser.current() else { return }
        currentUser["avatar"] = newAvatarName
        activityIndicator.startAnimating()
        currentUser.saveInBackground { [weak self] (completed: Bool, error: Error?) in
            self?.activityIndicator.stopAnimating()
            if error != nil {
                print("updateAvatarInParse - failed to update avatar name To Parse")
                return
            } else {
                if completed == true {
                    print("updateAvatarInParse - successfully saved to Parse")
                    self?.popViewController()
                } else {
                    print("updateAvatarInParse - failed to complete upload")
                }
            }
        }
    }
    
}











