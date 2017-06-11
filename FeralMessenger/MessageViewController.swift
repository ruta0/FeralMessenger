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
    
    var container: NSPersistentContainer? = CoreDataManager.persistentContainer // default container
    var selectedUser: CoreUser?
    var fetchedResultsController: NSFetchedResultsController<CoreMessage>?
    
    func insertToCoreMessage(with pfObject: Message) {
        self.container?.performBackgroundTask { context in
            let newCoreMessage = CoreMessage(context: context)
            newCoreMessage.created_at = pfObject.createdAt! as NSDate
            newCoreMessage.sms = pfObject["sms"] as? String
            newCoreMessage.updated_at = pfObject.updatedAt! as NSDate
            newCoreMessage.sender_name = pfObject["senderName"] as? String
            newCoreMessage.receiver_name = pfObject["receiverName"] as? String
            newCoreMessage.id = pfObject.objectId!
            try? context.save()
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
                print("updateCoreMessageFromParse - Failed to save context: ", err)
            }
            self?.performFetchFromCoreData()
            self?.printDatabaseStats()
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
            self.fetchedResultsController = NSFetchedResultsController<CoreMessage>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            self.fetchedResultsController?.delegate = self
            do {
                try self.fetchedResultsController?.performFetch()
                self.tableView.reloadData()
                self.scrollToLastCellItem()
            } catch let err {
                print("performFetch failed to fetch: \(err)")
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
        beginRefresh()
        if let sms = messageTextField.text, !sms.isEmpty, let receiverName = selectedUser?.username {
            createMessageInParse(with: sms, receiverName: receiverName, completion: { [weak self] (message: Message) in
                self?.insertToCoreMessage(with: message)
                self?.scrollToLastCellItem()
                self?.messageTextField.text = ""
                // insert new coreMessage to CoreData
//                self?.performFetchFromCoreData()
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

extension MessageViewController: UITableViewDataSource {
    
    /// Note: notice that there is a footer in the storyboard to offer the additional space offset for the textfield
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? DetailCell {
            if let coreMessage = fetchedResultsController?.object(at: indexPath) {
                cell.messageTextView.text = coreMessage.sms!
                let size = CGSize(width: 250, height: 300)
                let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
                let estimatedFrame = NSString(string: coreMessage.sms!).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)], context: nil)
                // outgoing message
                if coreMessage.sender_name == PFUser.current()!.username! {
                    cell.messageTextView.backgroundColor = UIColor.miamiBlue()
                    cell.messageTextView.textColor = UIColor.black
                    cell.messageTextView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 8 - 8, y: estimatedFrame.width + 16 + 8, width: estimatedFrame.width + 16 + 8, height: estimatedFrame.height + 20)
                } else if coreMessage.receiver_name == PFUser.current()!.username! {
                    // incoming message
                    cell.messageTextView.backgroundColor = UIColor.mediumBlueGray()
                    cell.messageTextView.textColor = UIColor.white
                    cell.messageTextView.frame = CGRect(x: 8, y: 0, width: estimatedFrame.width + 16 + 8, height: estimatedFrame.height + 20)
                }
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
}


// MARK: - UITableViewDelegate

extension MessageViewController {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let sms = fetchedResultsController?.object(at: indexPath).sms {
            let size = CGSize(width: 250, height: 300)
            let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: sms).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)], context: nil)
            return estimatedFrame.height + 20
        }
        return CGFloat(84)
    }
    
}


// MARK: - NSFetchedResultsControllerDelegate

extension MessageViewController: NSFetchedResultsControllerDelegate {
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: tableView.insertSections([sectionIndex], with: .fade)
        case .delete: tableView.deleteSections([sectionIndex], with: .fade)
        default: break
        }
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
}





































