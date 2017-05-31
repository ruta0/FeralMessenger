//
//  FetchedResultsCollectionViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/28/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import CoreData


class FetchedResultsCollectionViewController: UICollectionViewController, NSFetchedResultsControllerDelegate {
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("controller will change content")
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("controller did change content")
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        guard let collectionView = collectionView else { return }
        collectionView.performBatchUpdates({
            switch type {
            case .insert:
                collectionView.insertSections(IndexSet(integer: sectionIndex))
            case .delete:
                collectionView.deleteSections(IndexSet(integer: sectionIndex))
            default:
                break
            }
        }, completion: nil)
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        guard let collectionView = collectionView else { return }
        collectionView.performBatchUpdates({
            switch type {
            case .insert:
                collectionView.insertItems(at: [newIndexPath!])
            case .delete:
                collectionView.deleteItems(at: [indexPath!])
            case .update:
                collectionView.reloadItems(at: [indexPath!])
            case .move:
                collectionView.deleteItems(at: [indexPath!])
                collectionView.insertItems(at: [newIndexPath!])
            }
        }, completion: nil)
    }

}


















