//
//  CoreDataStack.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/27/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import CoreData


final class CoreDataStack {
    
    static let shared = CoreDataStack()
    
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Feral")
        container.loadPersistentStores(completionHandler: { (storeDescription: NSPersistentStoreDescription, err: Error?) in
            if err != nil {
                fatalError("Error loading container: \(String(describing: err))")
            }
        })
        return container
    }()
    
    // main queue context
    static var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    class func emptyPersistentContainer() {
        let context = self.viewContext
        context.perform {
            do {
                let entityNames = ["CoreUser", "CoreMessage"]
                for entityName in entityNames {
                    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
                    let fetchedObjects = try context.fetch(fetchRequest) as? [NSManagedObject]
                    for object in fetchedObjects! {
                        context.delete(object)
                    }
                }
                try context.save()
            } catch let err {
                print("Error while emptying persistent store", err)
            }
        }
    }
    
    class func saveContext() {
        let context = self.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // handle this error properly in production!!!
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}






























