//
//  MessageViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/30/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import Parse
import CoreData


// MARK: - Core Data

final class MessageViewController: DetailViewController {
    
    fileprivate let cellID = "DetailCell"
    fileprivate let segueID = "SettingsViewControllerSegue"
    
    var container: NSPersistentContainer? = CoreDataManager.persistentContainer
    var selectedUser: CoreUser?
    fileprivate var fetchedResultsController: NSFetchedResultsController<CoreMessage>?
    
    func insertToCoreMessage(with pfObject: Message) {
        self.container?.performBackgroundTask { context in
            let newCoreMessage = CoreMessage(context: context)
            newCoreMessage.created_at = pfObject.createdAt! as NSDate
            newCoreMessage.sms = pfObject["sms"] as? String
            newCoreMessage.updated_at = pfObject.updatedAt! as NSDate
            newCoreMessage.sender_name = pfObject["senderName"] as? String
            newCoreMessage.receiver_name = pfObject["receiverName"] as? String
            newCoreMessage.id = pfObject.objectId!
            do {
                try context.save()
            } catch let err {
                print("failed to save new message to coredata: ", err.localizedDescription)
            }
        }
    }
    
    func updateCoreMessage(with pfObjects: [PFObject]) {
        self.container?.performBackgroundTask { [weak self] context in
            for pfObject in pfObjects {
                _ = try? CoreMessage.findOrCreateCoreMessage(matching: pfObject, in: context)
            }
            do {
                try context.save()
            } catch let err {
                print("updateCoreMessageFromParse - Failed to save context: ", err.localizedDescription)
            }
            self?.performFetchFromCoreData()
        }
    }
    
    private func printDatabaseStats() {
        guard let context = container?.viewContext else { return }
        context.perform {
            if let messageCount = try? context.count(for: CoreMessage.fetchRequest()) {
                print(messageCount, "messages in the core data store")
            }
        }
    }
    
    private func performFetchFromCoreData() {
        guard let context = container?.viewContext, let senderName = selectedUser?.username, let receiver = PFUser.current()?.username else { return }
        context.perform {
            let request: NSFetchRequest<CoreMessage> = CoreMessage.defaultFetchRequest(from: senderName, to: receiver)
            request.fetchLimit = 200
            request.fetchBatchSize = 5
            self.fetchedResultsController = NSFetchedResultsController<CoreMessage>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            self.fetchedResultsController?.delegate = self
            do {
                try self.fetchedResultsController?.performFetch()
                self.tableView.reloadData()
                self.scrollToLastCellItem()
            } catch let err {
                print("performFetch failed to fetch: \(err.localizedDescription)")
            }
        }
    }
    
    override func setupNavigationController() {
        super.setupNavigationController()
        profileButton.addTarget(self, action: #selector(presentProfileViewController(_:)), for: UIControlEvents.touchUpInside)
        if let username = selectedUser?.username {
            titleButton.setTitle(username, for: UIControlState.normal)
        }
    }
    
    override func sendButton_tapped(_ sender: UIButton) {
        // clearing out messageTextField immediately
        let message = messageTextField.text
        clearMessageTextField()
        // handle sending message
        beginRefresh()
        if let sms = message, !sms.isEmpty, let receiverName = selectedUser?.username {
            createMessageInParse(with: sms, receiverName: receiverName, completion: { [weak self] (message: Message) in
                self?.insertToCoreMessage(with: message)
                self?.performFetchFromCoreData() // not what I wanted, but ok...
                self?.endRefresh()
            })
        }
    }
    
}


// MARK: - Lifecycle

extension MessageViewController {
    
    func presentProfileViewController(_ sender: UIButton) {
        // perform segue to settings
        print("Not supported at this moment")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        beginRefresh()
        if let username = selectedUser?.username {
            readMessageInParse(with: username) { [weak self] (messages: [PFObject]?) in
                guard let messages = messages else {
                    print("readMessageInParse: returned nil messages from Parse")
                    return
                }
                self?.updateCoreMessage(with: messages)
                self?.endRefresh()
            }
        } else {
            print("selectedUser is nil")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueID {
            print("segueID is registered")
        }
    }
    
}


// MARK: - UITableViewDataSource

extension MessageViewController {
    
    /// Note: notice that there is a footer in the storyboard to offer the additional space offset for the textfield
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? DetailCell {
            if let coreMessage = fetchedResultsController?.object(at: indexPath) {
                cell.messageTextView.text = coreMessage.sms!
                let size = CGSize(width: 250, height: 300)
                let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
                let estimatedFrame = NSString(string: coreMessage.sms!).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)], context: nil)
                // outgoing message
                if coreMessage.sender_name == PFUser.current()!.username! {
                    cell.messageTextView.backgroundColor = UIColor.miamiBlue()
                    cell.messageTextView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 8, y: 8, width: estimatedFrame.width + 16, height: estimatedFrame.height + 16)
                } else if coreMessage.receiver_name == PFUser.current()!.username! {
                    // incoming message
                    cell.messageTextView.backgroundColor = UIColor.mediumBlueGray()
                    cell.messageTextView.frame = CGRect(x: 8, y: 8, width: estimatedFrame.width + 16, height: estimatedFrame.height + 16)
                }
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
}


// MARK: - UITableViewDelegate

extension MessageViewController {
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let section = fetchedResultsController?.sections?[section] else {
            print("fetchedResultsController?.sections?[section] is nil")
            return nil
        }
        return section.name
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let sms = fetchedResultsController?.object(at: indexPath).sms {
            let size = CGSize(width: 250, height: 300)
            let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: sms).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)], context: nil)
            return estimatedFrame.height + 16 + 16
        }
        return CGFloat(84)
    }
    
}


// MARK: - NSFetchedResultsControllerDelegate

extension MessageViewController: NSFetchedResultsControllerDelegate {
    
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
        case .delete:
            if let indexPath = indexPath {
                self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            }
        case .update:
            if let indexPath = indexPath {
                self.tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            }
        case .move:
            if let indexPath = indexPath {
                self.tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.fade)
            }
            if let newIndexPath = newIndexPath {
                self.tableView.insertRows(at: [newIndexPath], with: UITableViewRowAnimation.fade)
            }
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.tableView.endUpdates()
        if let lol = fetchedResultsController?.fetchedObjects {
            print(lol)
        }
    }
    
}





































