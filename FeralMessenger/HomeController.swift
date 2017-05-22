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
    
}
