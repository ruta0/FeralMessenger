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

class MessageViewController: DetailViewController {
    
    fileprivate let cellID = "DetailCell"
    
    var container: NSPersistentContainer? = CoreDataStack.persistentContainer
    var fetchedResultsController: NSFetchedResultsController<CoreMessage>?
    
    func insertToCoreMessage(with pfObject: Message) {
        if let context = container?.newBackgroundContext() {
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
    
    func persistToCoreMessage(with pfObjects: [PFObject]) {
        self.container?.performBackgroundTask { [weak self] context in
            for pfObject in pfObjects {
                _ = try? CoreMessage.findOrCreateCoreMessage(matching: pfObject, in: context)
            }
            do {
                try context.save()
            } catch let err {
                print("updateCoreMessageFromParse - Failed to save context", err)
            }
            self?.performFetchFromCoreData()
            self?.reloadCollectionView()
//            self?.printDatabaseStats()
        }
    }
    
    private func printDatabaseStats() {
        guard let context = container?.viewContext else { return }
        context.perform {
            if let userCount = try? context.count(for: CoreMessage.fetchRequest()) {
                print(userCount, "users in the core data store")
            }
        }
    }
    
    func performFetchFromCoreData() {
        if let context = container?.viewContext, selectedUserName != nil {
            let request: NSFetchRequest<CoreMessage> = CoreMessage.fetchRequest()
            let predicate = NSPredicate(format: "receiver_name == %@ AND sender_name == %@", selectedUserName!, (PFUser.current()?.username!)!)
            let inversePredicate = NSPredicate(format: "receiver_name == %@ AND sender_name == %@", (PFUser.current()?.username!)!, selectedUserName!)
            let compoundedPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate, inversePredicate])
            request.sortDescriptors = [NSSortDescriptor(key: "created_at", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
            request.predicate = compoundedPredicate
            fetchedResultsController = NSFetchedResultsController<CoreMessage>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController?.delegate = self
            context.perform {
                do {
                    try self.fetchedResultsController?.performFetch()
                    self.collectionView?.reloadData()
                } catch let err {
                    print("performFetch failed to fetch: - \(err)")
                }
            }
        }
    }
    
    override func sendMessage() {
        super.sendMessage()
        if let sms = inputTextField.text, sms != "" {
            uploadToParse(with: sms, completion: { [weak self] (pfObject: Message) in
                self?.insertToCoreMessage(with: pfObject)
                self?.scrollToLastCellItem()
                self?.inputTextField.text = ""
            })
        }
    }
    
}


// MARK: - Lifecycle

extension MessageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadMessageFromParse(with: selectedUserName!) { [weak self] (pfObjects: [PFObject]) in
            self?.persistToCoreMessage(with: pfObjects)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        scrollToLastCellItem()
    }
    
}


// MARK: - UICollectionViewDataSource

extension MessageViewController {
    
    /// Note: notice that there is a footer in the storyboard to offer the additional space offset for the textfield
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! DetailCell
        if let coreMessage = fetchedResultsController?.object(at: indexPath) {
            cell.messageTextView.text = coreMessage.sms!
            cell.profileImageView.image = #imageLiteral(resourceName: "ProfileImage")
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: coreMessage.sms!).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)], context: nil)
            // incoming message
            if coreMessage.sender_name != PFUser.current()!.username! {
                cell.bubbleView.frame = CGRect(x: 8 + 30 + 8, y: 0, width: estimatedFrame.width + 16 + 8, height: estimatedFrame.height + 20)
                cell.messageTextView.frame = CGRect(x: 8 + 30 + 8 + 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                cell.messageTextView.textColor = UIColor.black
                cell.profileImageView.isHidden = false
                cell.bubbleView.backgroundColor = UIColor.lightBlue()
            } else {
                // outgoing message
                cell.bubbleView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 8 - 8, y: 0, width: estimatedFrame.width + 16 + 8, height: estimatedFrame.height + 20)
                cell.messageTextView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                cell.messageTextView.textColor = UIColor.white
                cell.profileImageView.isHidden = true
                cell.bubbleView.backgroundColor = UIColor.mediumBlueGray()
                cell.messageTextView.textColor = UIColor.white
            }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DetailViewFooter", for: indexPath)
            footerView.backgroundColor = UIColor.clear
            return footerView
        default:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DetailViewFooter", for: indexPath)
            footerView.backgroundColor = UIColor.clear
            return footerView
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
}


// MARK: - UICollectionViewDelegateFlowLayout

extension MessageViewController {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let sms = fetchedResultsController?.object(at: indexPath).sms {
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: sms).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)], context: nil)
            return CGSize(width: view.frame.width, height: estimatedFrame.height+20)
        }
        return CGSize(width: view.frame.width, height: 84)
    }
    
}








































