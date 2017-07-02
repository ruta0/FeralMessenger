//
//  AvatarViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/30/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import Parse


class AvatarViewController: DisclosureViewController, ParseUsersManagerDelegate {
    
    // MARK: - Main bundle
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupParseManager()
        fetchAvatarsFromPropertyList(for: fileName, of: "plist")
    }
    
    // MARK: - Parse
    
    var currentUser: PFUser {
        return PFUser.current()!
    }
    
    var parseManager: ParseManager?
    
    func setupParseManager() {
        parseManager = ParseManager()
        parseManager?.userDelegate = self
    }
    
    func didUpdateCurrentUser(completed: Bool, error: Error?) {
        endLoadingAnime()
        if let err = error {
            self.scheduleNavigationPrompt(with: err.localizedDescription, duration: 4)
        } else {
            if completed == true {
                self.popViewController()
            }
        }
    }
    
    override func updateAvatar(with name: String) {
        beginLoadingAnime()
        parseManager?.updateUser(for: "avatar", newValue: name)
    }
    
    // MARK: - UICollectionViewDataSource
    
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
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.id, for: indexPath) as? PhotoCell {
            if let avatar = avatars?[indexPath.item] {
                cell.avatar = avatar
            }
            return cell
        } else {
            return UICollectionViewCell()
        }
    }
    
}
