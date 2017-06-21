//
//  CloudKitManager.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/16/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import CloudKit
import UIKit

protocol CloudKitSubscriptionDelegate {
    
    // MARK: - Protocol
    
    func didSubscribed(subscription: CKSubscription?, error: Error?) // add observers to AppDelegate and handle notification
    func didUnsubscribed(subscription: String?, error: Error?) // ignore
    func didCreateRecord(ckRecord: CKRecord?, error: Error?) // handle this and update UI
    func didDeleteRecord() // handle this and update UI
    
}

extension CloudKitSubscriptionDelegate {
    
    // MARK: - Optional protocol methods
    
    func didReceiveNotificationFromSubscription(ckqn: CKQueryNotification) {}
    
}


class CloudKitManager: NSObject {
    
    // MARK: - Lifecycle
        
    var delegate: CloudKitSubscriptionDelegate?
    
    // MARK: - Subscription
    
    /// dynamicRecordType should be the current user's username
    func subscribeToRecord(database: CKDatabase, subscriptionID: String, dynamicRecordType: String) {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let subscription = CKQuerySubscription(recordType: dynamicRecordType,
                                               predicate: predicate,
                                               options: [.firesOnRecordUpdate, .firesOnRecordCreation, .firesOnRecordDeletion])
        // setup notification type
        let notificationInfo = CKNotificationInfo()
        notificationInfo.shouldBadge = true
        notificationInfo.shouldSendContentAvailable = true // do NOT remove
        notificationInfo.alertBody = "You have a new message"
        subscription.notificationInfo = notificationInfo
        database.save(subscription) { (subscription: CKSubscription?, err: Error?) in
            self.delegate?.didSubscribed(subscription: subscription, error: err)
        }
    }
    
    func unsubscribeToRecord(database: CKDatabase, subscriptionID: String) {
        database.delete(withSubscriptionID: subscriptionID) { (subscriptionString: String?, err: Error?) in
            self.delegate?.didUnsubscribed(subscription: subscriptionString, error: err)
        }
    }
    
    // MARK: - CKRecord
    
    /// dynamicRecordType should be the current user's username
    func createCKRecord(in database: CKDatabase, dataToSend: [String : Bool]?, dynamicRecordType: String) {
        let payloadRecord = CKRecord(recordType: dynamicRecordType)
        if let data = dataToSend {
            payloadRecord.setValuesForKeys(data)
            print(payloadRecord)
        } else {
            print("createCKRecord: - payload is nil")
        }
        database.save(payloadRecord) { (record: CKRecord?, error: Error?) in
            self.delegate?.didCreateRecord(ckRecord: record, error: error)
        }
    }
    
    // called after didReadMessage()
    func deleteCKRecord() {
        delegate?.didDeleteRecord()
    }
    
    // MARK: - Notification
    
    /// This method will broadcast "iCloudRemoteNotificationReceived" in userInfo
    func postNotifications(userInfo: [AnyHashable : Any], object: Any?) {
        let ckQueryNotification = CKQueryNotification(fromRemoteNotificationDictionary: userInfo)
        print(ckQueryNotification)
        let notification = Notification(name: Notification.Name(CloudKitNotifications.NotificationReceived), object: object, userInfo: [CloudKitNotifications.NotificationKey: ckQueryNotification])
        DispatchQueue.main.async {
            NotificationCenter.default.post(notification)
        }
    }
    
    func resetBadgeCount() {
        let badgeReset = CKModifyBadgeOperation(badgeValue: 0)
        badgeReset.modifyBadgeCompletionBlock = { (error) -> Void in
            if error == nil {
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        }
        CKContainer.default().add(badgeReset)
    }
    
    // MARK: - Observers
    
    var cloudKitObserver: NSObjectProtocol?
    
    /// This method requires the implementation of an optional protocol method as local handler upon receiving a notification from the AppDelegate: - didReceiveNotificationFromSubscription()
    func setupLocalObserver() {
        cloudKitObserver = NotificationCenter.default.addObserver(forName: Notification.Name(CloudKitNotifications.NotificationReceived), object: nil, queue: OperationQueue.main, using: { (notification: Notification) in
            if let ckqn = notification.userInfo?[CloudKitNotifications.NotificationKey] as? CKQueryNotification {
                self.delegate?.didReceiveNotificationFromSubscription(ckqn: ckqn)
            }
        })
    }
    
    func removeLocalObserver(observer: Any) {
        if #available(iOS 9, *) {
            NotificationCenter.default.removeObserver(observer, name: Notification.Name(CloudKitNotifications.NotificationReceived), object: nil)
        }
    }
    
    // MARK: - Error handler
    
    func retryAfterError(error: NSError?, withSelector selector: Selector) {
        if let retryInterval = error?.userInfo[CKErrorRetryAfterKey] as? TimeInterval {
            DispatchQueue.main.async {
                Timer.scheduledTimer(
                    timeInterval: retryInterval,
                    target: self,
                    selector: selector,
                    userInfo: nil,
                    repeats: false)
            }
        }
    }

}

































