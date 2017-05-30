//
//  DetailController.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/22/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import Parse
import CoreData


extension DetailViewController {
    
    // MARK: - Parse stuff
    
    func downloadMessageFromParse(with selectedUserName: String) {
        guard let query = Message.query(receiverName: selectedUserName, senderName: (PFUser.current()?.username)!) else { return }
        query.findObjectsInBackground { [weak self] (pfObjects: [PFObject]?, error: Error?) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                guard let pfObjects = pfObjects else {
                    print("updateCoreMessageFromParse - pfObjects are nil")
                    return
                }
                self?.persistToCoreMessage(with: pfObjects)
            }
        }
    }
    
    func uploadToParse(with sms: String) {
        let pfObject = Message()
        pfObject["sms"] = sms
        pfObject["image"] = ""
        pfObject["senderName"] = selectedUserName!
        pfObject["receiverName"] = (PFUser.current()?.username)!
        pfObject.saveInBackground { [weak self] (completed: Bool, error: Error?) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                if completed == true {
                    self?.insertToCoreMessage(with: pfObject)
                    // reload the collectionview
                    self?.scrollToLastCellItem()
                }
            }
        }
    }
    
    // MARK: - Core Data stuff
    
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
    
}


























