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
import CloudKit


final class MessageViewController: DetailViewController {
    
    // MARK: - NavigationController
    
    override func setupNavigationController() {
        super.setupNavigationController()
        // profileButton
        rightBarButton.addTarget(self, action: #selector(showProfileViewController(_:)), for: UIControlEvents.touchUpInside)
        if let avatarName = selectedCoreUser?.profile_image, let image = UIImage(named: avatarName) {
            rightBarButton.setBackgroundImage(image, for: UIControlState.normal)
        }
        // titleButton
        if let username = selectedCoreUser?.username {
            titleButton.setTitle(username, for: UIControlState.normal)
        }
    }
    
    // MARK: - Core Data
    
    var container: NSPersistentContainer? = CoreDataManager.persistentContainer
    
    var selectedCoreUser: CoreUser?
    
    fileprivate var fetchedResultsController: NSFetchedResultsController<CoreMessage>?
    
    func insertToCoreMessage(with pfObject: Message) {
        if let context = container?.viewContext {
            let newCoreMessage = CoreMessage(context: context)
            newCoreMessage.created_at = pfObject.createdAt! as NSDate
            newCoreMessage.sms = pfObject["sms"] as? String
            newCoreMessage.updated_at = pfObject.updatedAt! as NSDate
            newCoreMessage.senderID = pfObject["senderID"] as? String
            newCoreMessage.receiverID = pfObject["receiverID"] as? String
            newCoreMessage.id = pfObject.objectId!
            do {
                try context.save()
            } catch let err {
                print("failed to save new message to coredata: ", err.localizedDescription)
            }
        }
    }
    
    // MARK: - Lifecycle
    
    private let segueID = "SettingsViewControllerSegue"
    
    // animate a popover instead of performing yet another segue
    func showProfileViewController(_ sender: UIButton) {
        print("Not supported at this moment")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupParseManagerDelegate()
        setupCKManagerDelegates()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueID {
            print("segueID is registered")
        }
    }
    
    // MARK: - UITableViewDataSource
    
    private let cellID = "DetailCell"
    
    /// Note: notice that there is a footer in the storyboard to offer the additional space offset for the textfield
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as? DetailCell {
            if let coreMessage = fetchedResultsController?.object(at: indexPath) {
                cell.messageTextView.text = coreMessage.sms!
                let size = CGSize(width: 250, height: 300)
                let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
                let estimatedFrame = NSString(string: coreMessage.sms!).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)], context: nil)
                // outgoing message
                if coreMessage.senderID == PFUser.current()!.objectId {
                    cell.messageTextView.backgroundColor = UIColor.miamiBlue()
                    cell.messageTextView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 8, y: 8, width: estimatedFrame.width + 16, height: estimatedFrame.height + 16)
                } else if coreMessage.receiverID == PFUser.current()!.objectId {
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
    
    // MARK: - UITableViewDelegate
    
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


// MARK: - ParseMessengerManagerDelegate

extension MessageViewController: ParseMessengerManagerDelegate {
    
    fileprivate func setupParseManagerDelegate() {
        parseManager?.messengerDelegate = self
    }
    
    func updateCoreMessage(with pfObjects: [PFObject]) {
        self.container?.performBackgroundTask { context in
            for pfObject in pfObjects {
                _ = try? CoreMessage.findOrCreateCoreMessage(matching: pfObject, in: context)
            }
            do {
                try context.save()
            } catch let err {
                print("updateCoreMessageFromParse - Failed to save context: ", err.localizedDescription)
            }
            self.performFetchFromCoreData()
        }
    }
    
    private func performFetchFromCoreData() {
        guard let context = container?.viewContext, let senderID = selectedCoreUser?.id, let receiverID = PFUser.current()?.objectId else { return }
        context.perform {
            let request: NSFetchRequest<CoreMessage> = CoreMessage.defaultFetchRequest(from: senderID, to: receiverID)
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
    
    func didReceiveMessages(with messages: [PFObject]) {
        updateCoreMessage(with: messages)
    }
    
    func didReceiveMessage(with message: Message) {
        insertToCoreMessage(with: message)
    }
    
    func didSendMessage(with message: Message) {
        // 1. play sound to confirm successfully upload to Parse
        playSound()
        
        // 2. create record in the CloudKit's pubDatabase to receiver's subscription
        guard let receiverID = message["receiverID"] as? String, let sms = message["sms"] as? String else { return }
        ckManager?.createCKRecord(in: pubDatabase, receiverID: receiverID, sms: sms)
        
        // 3. fetch for new message when a PUSH payload comes in
        insertToCoreMessage(with: message)
    }
    
}


// MARK: - CloudKitSubscriptionDelegate

extension MessageViewController: CloudKitSubscriptionDelegate {
    
    fileprivate func setupCKManagerDelegates() {
        ckManager?.delegate = self
    }
    
    func cloudKitHandleSubscriptionNotification(ckqn: CKQueryNotification) {
        if ckqn.subscriptionID == subscriptionID {
            if let recordID = ckqn.recordID {
                switch ckqn.queryNotificationReason {
                case .recordCreated:
                    print(recordID)
                    ckManager?.delegate = self
                case .recordDeleted:
                    // ignore, for now
                    break
                default:
                    break
                }
            }
        }
    }
    
    func didSubscribed(subscription: CKSubscription?, error: Error?) {
        // ignore
        print("subscribed to: ", subscription!.subscriptionID)
    }
    
    func didUnsubscribed(subscription: String?, error: Error?) {
        // ignore
        print("unsubscribed from: ", subscription!)
    }
    
    func didCreateRecord(ckRecord: CKRecord?, error: Error?) {
        // called after didSendMessage
        if let err = error as? CKError {
            if err.code == CKError.Code.notAuthenticated {
                // invite user to login with iCloud account
                performAlert(error: err.localizedDescription)
            } else {
                // unexpected error
                print(err)
            }
        } else {
            print(ckRecord!)
        }
    }
    
    func didDeleteRecord() {
        // called after didReadMessage
        print("deleted")
    }
    
    private func performAlert(error: String) {
        let alert = UIAlertController(title: error, message: "Please login to iCloud to enable Push Notification and auto-refresh", preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(ok)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
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
            if let newIndexPath = newIndexPath {
                self.tableView.insertRows(at: [newIndexPath], with: UITableViewRowAnimation.fade)
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
        
        // a little too expensive, think of something better!
        self.tableView.reloadData()
        self.scrollToLastCellItem()
    }
    
}





































