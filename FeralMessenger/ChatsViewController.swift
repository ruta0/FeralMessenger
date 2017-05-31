//
//  ChatsViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/30/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import Parse
import CoreData


// MARK: - Core Data

final class ChatsViewController: MasterViewController {
    
    fileprivate let cellID = "MasterCell"
    
    var container: NSPersistentContainer? = CoreDataStack.persistentContainer
    
    lazy var fetchedResultsController: NSFetchedResultsController<CoreUser> = {
        let frc = NSFetchedResultsController(fetchRequest: CoreUser.defaultFetchedRequest, managedObjectContext: CoreDataStack.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    func persistToCoreUser(with pfObjects: [PFObject]) {
        self.container?.performBackgroundTask { [weak self] context in
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
//            self?.printDatabaseStats()
        }
    }
    
    private func performFetchFromCoreData() {
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


// MARK: - Lifecycle

extension ChatsViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadUserFromParse { [weak self] (pfObjects: [PFObject]) in
            self?.persistToCoreUser(with: pfObjects)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailViewControllerSegue" {
            guard let selectedCell = sender as? MasterCell else {
                print("unexpected sender of cell")
                return
            }
            let messageViewController = segue.destination as! MessageViewController
            messageViewController.selectedUserName = selectedCell.usernameLabel.text!
            messageViewController.container = container
        }
    }
    
}


// MARK: - UICollectionViewDataSource

extension ChatsViewController {
    
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



















