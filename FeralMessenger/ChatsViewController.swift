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
    
    fileprivate let masterCellID = "MasterCell"
    fileprivate let segueID = "DetailViewControllerSegue"
    
    var container: NSPersistentContainer? = CoreDataManager.persistentContainer // default container
    
    lazy fileprivate var fetchedResultsController: NSFetchedResultsController<CoreUser> = {
        let frc = NSFetchedResultsController(fetchRequest: CoreUser.defaultFetchRequest(with: nil), managedObjectContext: CoreDataManager.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    @IBAction func refresh(_ sender: UIRefreshControl) {
        beginRefresh()
        readUserInParse(with: nil) { [weak self] (users: [PFObject]?) in
            guard let users = users else {
                print("readUserInParse: returned nil users from Parse")
                return
            }
            self?.updateCoreUser(with: users)
            self?.endRefresh()
        }
    }
    
    func updateCoreUser(with pfObjects: [PFObject]) {
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
            // self?.printDatabaseStats()
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
            self.tableView.reloadData()
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
        beginRefresh()
        readUserInParse(with: nil) { [weak self] (users: [PFObject]?) in
            guard let users = users else {
                print("readUserInParse: returned nil users from Parse")
                return
            }
            self?.updateCoreUser(with: users)
            self?.endRefresh()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueID {
            guard let selectedCell = sender as? MasterCell, let messageViewController = segue.destination as? MessageViewController else {
                print("unexpected sender of cell")
                return
            }
            messageViewController.selectedUser = selectedCell.coreUser
            messageViewController.container = container
        }
    }
    
}


// MARK: - UITableViewDataSource

extension ChatsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections, sections.count > 0 else {
            return 0
        }
        return sections[section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: masterCellID, for: indexPath) as? MasterCell {
            let coreUser = fetchedResultsController.object(at: indexPath)
            cell.coreUser = coreUser
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
}


// MARK: - NSFetchedResultsControllerDelegate

extension ChatsViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            self.tableView.insertSections([sectionIndex], with: UITableViewRowAnimation.fade)
        case .delete:
            self.tableView.deleteSections([sectionIndex], with: UITableViewRowAnimation.fade)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                self.tableView.insertRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            }
            break
        case .delete:
            if let indexPath = indexPath {
                self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            }
            break
        case .update:
            if let indexPath = indexPath {
                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            }
            break
        case .move:
            if let indexPath = indexPath {
                self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            }
            if let newIndexPath = newIndexPath {
                self.tableView.insertRows(at: [newIndexPath], with: UITableViewRowAnimation.fade)
            }
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
    }
    
}
















