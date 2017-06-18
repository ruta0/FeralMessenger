//
//  CloudKitManager.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/16/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import CloudKit

protocol CloudKitSubscriptionDelegate {
    func didSubscribed(subscription: CKSubscription?, error: Error?) // add observers to AppDelegate and handle notification
    func didUnsubscribed(subscription: String?, error: Error?) // ignore
    func didCreateRecord(ckRecord: CKRecord?, error: Error?) // handle this and update UI
    func didDeleteRecord() // handle this and update UI
}


class CloudKitManager: NSObject {
        
    var delegate: CloudKitSubscriptionDelegate?
    
    // MARK: - Subscription
    
    func subscribeToMessage(database: CKDatabase, subscriptionID: String) {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let subscription = CKQuerySubscription(recordType: Cloud.Entity.Messages,
                                               predicate: predicate,
                                               subscriptionID: subscriptionID,
                                               options: [.firesOnRecordCreation, .firesOnRecordDeletion])
        database.save(subscription) { (savedSub: CKSubscription?, err: Error?) in
            self.delegate?.didSubscribed(subscription: savedSub, error: err)
        }
    }
    
    func unsubscribeToMessage(database: CKDatabase, subscriptionID: String) {
        database.delete(withSubscriptionID: subscriptionID) { (subscriptionString: String?, err: Error?) in
            self.delegate?.didUnsubscribed(subscription: subscriptionString, error: err)
        }
    }
    
    // MARK: - CKRecord
    
    // called after didSendMessage()
    func createCKRecord(in database: CKDatabase, receiverID: String, sms: String) {
        let payloadRecord = CKRecord(recordType: Cloud.Entity.Messages)
        payloadRecord.setValue(sms, forKey: "sms")
        database.save(payloadRecord) { (record: CKRecord?, error: Error?) in
            self.delegate?.didCreateRecord(ckRecord: record, error: error)
        }
    }
    
    private func retryAfterError() {
        
    }
    
    // called after didReadMessage()
    func deleteCKRecord() {
        delegate?.didDeleteRecord()
    }

}


















