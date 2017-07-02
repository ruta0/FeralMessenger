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


final class ChatsViewController: MasterViewController, ParseUsersManagerDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: - ParseManager + ParseUsersManagerDelegate
    
    var parseUsers: [PFObject]?
    
    var parseManager: ParseManager?
    
    private func setupParseManager() {
        parseManager = ParseManager()
        parseManager?.userDelegate = self
    }
    
    func fetchUsers() {
        beginLoadingAnime()
//        parseManager?.readFriends()
        parseManager?.readAllUsers(with: nil)
    }
    
    func didReadUsers(with users: [PFObject]?, error: Error?) {
        endLoadingAnime()
        if let err = error {
            scheduleNavigationPrompt(with: err.localizedDescription, duration: 4)
        } else {
            guard let users = users else { return }
            parseUsers = users
            updateCoreUser(with: users)
        }
    }
    
    // MARK: - CloudKitManager
    
    var ckManager: CloudKitManager?
    
    private func setupCKManager() {
        ckManager = CloudKitManager()
//        ckManager?.delegate = self
    }
    
    // MARK: - CoreData + NSFetchedResultsControllerDelegate
    
    var container: NSPersistentContainer? = CoreDataManager.persistentContainer
    
    lazy private var fetchedResultsController: NSFetchedResultsController<CoreUser> = {
        let frc = NSFetchedResultsController(fetchRequest: CoreUser.defaultFetchRequest(with: nil), managedObjectContext: CoreDataManager.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()
    
    private func performFetchFromCoreData() {
        guard let context = container?.viewContext else { return }
        context.perform {
            do {
                try self.fetchedResultsController.performFetch()
            } catch let err {
                self.scheduleNavigationPrompt(with: err.localizedDescription, duration: 4)
            }
            self.tableView.reloadData()
        }
    }
    
    func updateCoreUser(with pfObjects: [PFObject]) {
        self.container?.performBackgroundTask { context in
            for pfObject in pfObjects {
                _ = try? CoreUser.findOrCreateCoreUser(matching: pfObject, in: context)
            }
            do {
                try context.save()
            } catch let err {
                self.scheduleNavigationPrompt(with: err.localizedDescription, duration: 4)
            }
            self.performFetchFromCoreData()
        }
    }
        
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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupParseManager()
        fetchUsers()
        setupCKManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ckManager?.setupLocalObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ckManager?.removeLocalObserver(observer: self)
    }
        
    private let segueToDetailViewController = "SegueToDetailViewController"

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueToDetailViewController {
            if let selectedCell = sender as? MasterCell {
                guard let messageViewController = segue.destination as? MessageViewController else {
                    print("unexpected sender of cell")
                    return
                }
                let receiverID = selectedCell.coreUser?.id
                messageViewController.receiverID = receiverID
                messageViewController.selectedCoreUser = selectedCell.coreUser
                messageViewController.container = container
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    /// this method is called before performFetch!
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections, sections.count > 0 else {
            print("sections.count == 0")
            return 0
        }
        return sections[section].numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let masterCell = tableView.dequeueReusableCell(withIdentifier: MasterCell.id, for: indexPath) as? MasterCell else {
            return UITableViewCell()
        }
        masterCell.selectionStyle = UITableViewCellSelectionStyle.none
        let coreUser = fetchedResultsController.object(at: indexPath)
        masterCell.coreUser = coreUser
        return masterCell
    }
    
}
















