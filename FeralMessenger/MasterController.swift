//
//  HomeController.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/22/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import Parse
import CoreData


extension MasterViewController {
    
    func handleFatalErrorResponse(fatalError: Error) {
        let alert = UIAlertController(title: "Unexpected Error", message: fatalError.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Parse Auth
    
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
    
    func removeTokenFromKeychain() {
        let item = KeychainItem(service: KeychainConfiguration.serviceName, account: "auth_token", accessGroup: KeychainConfiguration.accessGroup)
        do {
            try item.deleteItem()
        } catch let err {
            print(err)
        }
    }
    
    func updateCoreUserFromParse() {
        guard let query = User.query() else { return }
        query.findObjectsInBackground { [weak self] ( pfObjects: [PFObject]?, error: Error?) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                guard let pfObjects = pfObjects else {
                    print("updateCoreUserFromParse - pfObjects are nil")
                    return
                }
                self?.container?.performBackgroundTask { [weak self] context in
                    for pfObject in pfObjects {
                        _ = try? CoreUser.findOrCreateCoreUser(matching: pfObject, in: context)
                    }
                    do {
                        try context.save()
                    } catch let err {
                        print("updateCoreUserFromParse - Failed to save context", err)
                    }
                    self?.performFetchFromCoreData()
                    self?.reloadColectionView()
                    self?.printDatabaseStats()
                }
            }
        }
    }
    
    // MARK: - Core Data stuff
    
    func performFetchFromCoreData() {
        guard let context = container?.viewContext else { return }
        context.perform {
            do {
                try self.fetchedResultsController.performFetch()
            } catch let err {
                print("performFetchFromCoreData failed to fetch: - \(err)")
            }
        }
    }
    
    private func printDatabaseStats() {
        guard let context = container?.viewContext else { return }
        context.perform {
            if let userCount = try? context.count(for: CoreUser.fetchRequest()) {
                print(userCount, "users in the core data store")
            }
        }
    }
    
}





















