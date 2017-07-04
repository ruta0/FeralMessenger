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


final class MessageViewController: DetailViewController, NSFetchedResultsControllerDelegate, ParseMessengerManagerDelegate, CloudKitManagerDelegate {
    
    // MARK: - InputContainerView
    
    var receiverID: String?
    
    override func sendMessage(with message: String) {
        if let receiverID = receiverID, let senderID = currentUser.objectId {
            beginLoadingAnime()
            parseManager?.sendMessage(with: message, receiverID: receiverID, senderID: senderID, completion: { [weak self] (completed: Bool, err: Error?) in
                self?.playSound()
                self?.endLoadingAnime()
            })
        } // 3
    }
    
    // MARK: - NavigationController
    
    func updateNavigationController() {
        rightBarButton.addTarget(self, action: #selector(showProfileViewController(_:)), for: UIControlEvents.touchUpInside)
        if let avatarName = selectedCoreUser?.profile_image, let image = UIImage(named: avatarName) {
            rightBarButton.setBackgroundImage(image, for: UIControlState.normal)
        }
        if let username = selectedCoreUser?.username {
            titleButton.setTitle(username, for: UIControlState.normal)
        }
    }
    
    // MARK: - Core Data + NSFetchedResultsControllerDelegate

    var container: NSPersistentContainer? = CoreDataManager.persistentContainer
    
    var selectedCoreUser: CoreUser?
    
    private var fetchedResultsController: NSFetchedResultsController<CoreMessage>?
    
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
        guard let context = container?.viewContext, let senderID = selectedCoreUser?.id, let receiverID = currentUser.objectId else { return }
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
    
    // MARK: - Lifecycle
    
    // animate a popover instead of performing yet another segue
    func showProfileViewController(_ sender: UIButton) {
        // implement this
//        performSegue(withIdentifier: segueToProfileViewController, sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateNavigationController()
        setupParseManager() // 1
        fetchMessages() // 2
        setupCKManager()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ckManager?.subscribeToRecord(database: pubDatabase, subscriptionID: subscriptionID, dynamicRecordType: currentUser.username!)
        ckManager?.setupLocalObserver()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ckManager?.unsubscribeToRecord(database: pubDatabase, subscriptionID: subscriptionID)
        ckManager?.removeLocalObserver(observer: self)
    }
    
    private let segueToProfileViewController = "SegueToProfileViewController"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueToProfileViewController {
            print("Not supported at this moment")
        }
    }
    
    // MARK: - UITableViewDataSource
    
    /// Note: notice that there is a footer in the storyboard to offer the additional space offset for the textfield
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: DetailCell.id, for: indexPath) as? DetailCell {
            if let coreMessage = fetchedResultsController?.object(at: indexPath) {
                cell.messageTextView.text = coreMessage.sms!
                let size = CGSize(width: 250, height: 300)
                let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
                let estimatedFrame = NSString(string: coreMessage.sms!).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)], context: nil)
                // outgoing message
                if coreMessage.senderID == currentUser.objectId {
                    cell.messageTextView.backgroundColor = UIColor.miamiBlue
                    cell.messageTextView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 8, y: 8, width: estimatedFrame.width + 16, height: estimatedFrame.height + 16)
                } else if coreMessage.receiverID == currentUser.objectId {
                    // incoming message
                    cell.messageTextView.backgroundColor = UIColor.mediumBlueGray
                    cell.messageTextView.frame = CGRect(x: 8, y: 8, width: estimatedFrame.width + 16, height: estimatedFrame.height + 16)
                }
            }
            return cell
        } else {
            return UITableViewCell()
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController?.sections else {
            print("sections.count == 0")
            return 0
        }
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections, sections.count > 0 else {
            print("sections.count == 0")
            return 0
        }
        return sections[section].numberOfObjects
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let sms = fetchedResultsController?.object(at: indexPath).sms {
            let size = CGSize(width: 250, height: 300)
            let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: sms).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)], context: nil)
            return estimatedFrame.height + 16 + 16
        }
        return CGFloat(84)
    }
    
    // MARK: - ParseManager + ParseMessengerManagerDelegate
    
    var currentUser: PFUser {
        return PFUser.current()!
    }
    
    var parseManager: ParseManager?
    
    func setupParseManager() {
        parseManager = ParseManager()
        parseManager?.messengerDelegate = self
    }
    
    func fetchMessages() {
        if let receiverID = receiverID {
            beginLoadingAnime()
            parseManager?.readMessages(with: receiverID)
        } else {
            print("receiverID is nil")
        }
    }
    
    func didReceiveMessages(with messages: [PFObject]?, error: Error?) {
        endLoadingAnime()
        if let err = error {
            scheduleNavigationPrompt(with: err.localizedDescription, duration: 4)
        } else {
            guard let messages = messages else { return }
            updateCoreMessage(with: messages)
        }
    }
    
    func didReceiveMessage(with message: Message, error: Error?) {
        if let err = error {
            scheduleNavigationPrompt(with: err.localizedDescription, duration: 4)
        } else {
            insertToCoreMessage(with: message)
        }
    }
    
    func didSendMessage(with message: Message, error: Error?) {
        if let err = error {
            scheduleNavigationPrompt(with: err.localizedDescription, duration: 4)
        } else {
            // 1. play sound to confirm successfully upload to Parse
            playSound()
            guard let receiver_name = selectedCoreUser?.username, let sender_name = currentUser.username else { return }
            // 2. create record in the CloudKit's pubDatabase to receiver's subscription
            let dataToSend: [String : Bool] = [sender_name : false]
            ckManager?.createCKRecord(in: pubDatabase, dataToSend: dataToSend, dynamicRecordType: receiver_name)
            // 3. fetch for new message when a PUSH payload comes in
            insertToCoreMessage(with: message)
        }
    }
    
    // MARK: - CloudKitSubscriptionDelegate
    
    var ckManager: CloudKitManager?
    
    let pubDatabase = CKContainer.default().publicCloudDatabase
    
    let subscriptionID = "iCloud_Messages_Notification_Creations_Updates_Deletions"
    
    func setupCKManager() {
        ckManager = CloudKitManager()
        ckManager?.delegate = self
    }

    func ckErrorHandler(error: CKError) {
        print(error)
    }
    
    func didReceiveNotificationFromSubscription(ckqn: CKQueryNotification) {
        print(ckqn)
        if ckqn.subscriptionID == self.subscriptionID {
            if let recordID = ckqn.recordID {
                switch ckqn.queryNotificationReason {
                case .recordCreated:
                    pubDatabase.fetch(withRecordID: recordID, completionHandler: { (ckRecord: CKRecord?, err: Error?) in
                        // if a record cannot be fetched, just fetch a new batch of messages from Parse Server and tableView.reload()
                        // if fetch is success, either show a remote notification+change ChatsViewController's border color || reload tableView if the user is at MessageViewController
                        if err != nil {
                            print(err!)
                        } else {
                            print(ckRecord!)
                        }
                    })
                case .recordDeleted:
                    // when a user did read the push notification, delete it on iCloud and then handle UI
                    ckManager?.deleteCKRecord()
                case .recordUpdated:
                    pubDatabase.fetch(withRecordID: recordID, completionHandler: { (ckRecord: CKRecord?, err: Error?) in
                        if err != nil {
                            print(err!)
                        } else {
                            print(ckRecord!)
                        }
                    })
                }
            }
        }
    }
    
    func didSubscribed(subscription: CKSubscription?, error: Error?) {
        if error != nil {
            print(error!)
            if let err = error as? CKError {
                if err.code == CKError.Code.unknownItem {
                    ckManager?.createCKRecord(in: pubDatabase, dataToSend: nil, dynamicRecordType: currentUser.username!)
                    ckManager?.subscribeToRecord(database: pubDatabase, subscriptionID: subscriptionID, dynamicRecordType: currentUser.username!)
                } else if err.code == CKError.Code.serverRejectedRequest {
                    print(err.localizedDescription) // [development]: mostly about duplicate subs -> ignore
                }
            } else {
                performAlert(error: error!.localizedDescription)
            }
        } else {
            KeychainManager.shared.persistCKSubscription(subscription: subscription!)
            print("subscribed to: ", subscription!.subscriptionID)
        }
    }
    
    func didUnsubscribed(subscription: String?, error: Error?) {
        // ignore
        if error != nil {
            print(error!)
        } else {
            print("unsubscribed from: ", subscription!)
        }
    }
    
    func didCreateRecord(ckRecord: CKRecord?, error: Error?) {
        // called after didSendMessage
        if error != nil {
            if let err = error as? CKError {
                if err.code == CKError.Code.tooManyParticipants {
                    // implement this
                } else {
                    print(err)
                }
            } else {
                // error not related to CK, then give it another try
                performAlert(error: error!.localizedDescription)
            }
        } else {
            print(ckRecord!)
        }
    }
    
    func didDeleteRecord() {
        // called after didReadMessage
        print("deleted")
    }
    
    // refactor this to somewhere else...probably to some super class
    private func performAlert(error: String) {
        let alert = UIAlertController(title: error, message: "Please login to iCloud to enable Push Notification and auto-refresh", preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(ok)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}








































