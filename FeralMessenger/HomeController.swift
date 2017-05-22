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
            if error != nil {
                self.handleFatalErrorResponse(fatalError: error!)
            } else {
                self.tabBarController?.dismiss(animated: true, completion: nil)
            }
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
        query.findObjectsInBackground { (pfobjects: [PFObject]?, error: Error?) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                guard let pfobjects = pfobjects else { return }
                for pfObject in pfobjects {
                    let user = User()
                    user.profile_image = pfObject["profile_image"] as! String
                    user.username = pfObject["username"] as? String
                    user.timezone = pfObject["timezone"] as! String
                    self.users.append(user)
                }
                self.handleRefresh()
            }
        }
    }
    
    func handleRefresh() {
        collectionView?.reloadData()
        refreshController.endRefreshing()
    }
    
}





















