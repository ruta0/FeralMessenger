//
//  HomeController.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/22/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import Parse


extension HomeViewController {
    
    func performLogout() {
        PFUser.logOutInBackground { (error: Error?) in
            self.removeTokenFromKeychain()
            if error != nil {
                self.handleFatalErrorResponse(fatalError: error!)
            } else {
                self.tabBarController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func removeTokenFromKeychain() {
        let item = KeychainItem(service: KeychainConfiguration.serviceName, account: "auth_token", accessGroup: KeychainConfiguration.accessGroup)
        do {
            try item.deleteItem()
        } catch let err {
            print(err)
        }
    }
    
    func handleFatalErrorResponse(fatalError: Error) {
        let alert = UIAlertController(title: "Unexpected Error", message: fatalError.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    func fetchUsers() {
        guard let query = User.query() else { return }
        query.findObjectsInBackground { (pfObjects: [PFObject]?, error: Error?) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                guard let pfObjects = pfObjects else { return }
                for pfObject in pfObjects {
                    let user = User()
                    user.username = pfObject["username"] as? String
                    user.timezone = pfObject["timezone"] as! String
                    self.users.append(user)
                }
                self.reloadData()
            }
        }
    }
    
    func reloadData() {
        collectionView?.reloadData()
    }
    
    func handleRefresh() {
        collectionView?.reloadData()
        refreshController.endRefreshing()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailViewControllerSegue" {
            if let selectedCell = sender as? UICollectionViewCell {
                let indexPath = collectionView?.indexPath(for: selectedCell)!.row
                let vc = segue.destination as! DetailViewController
                vc.selectedUser = users[indexPath!]
            }
        }
    }
    
}





















