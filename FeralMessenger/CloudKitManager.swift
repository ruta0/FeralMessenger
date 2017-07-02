//
//  CloudKitManager.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/16/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import CloudKit
import UIKit


// MARK: - CloudKitSubscriptionDelegate

protocol CloudKitManagerDelegate {
    func ckErrorHandler(error: CKError)
}

extension CloudKitManagerDelegate {
    func didCreateRecord(ckRecord: CKRecord?) {} // handle this and update UI
    func didDeleteRecord() {} // handle this and update UI within Settings
    func didSubscribed(subscription: CKSubscription?) {} // add observers to AppDelegate and handle notification
    func didUnsubscribed(result: String?) {} // ignore
    func didReceiveNotificationFromSubscription(ckqn: CKQueryNotification) {}
}


// MARK: - CloudKitManager

class CloudKitManager: NSObject {

    var delegate: CloudKitManagerDelegate?
    
    // MARK: - Subscription
    
    var isSubscriptionLocallyCached: Bool?
    
    /// dynamicRecordType should be the current user's username
    /// subscription must be called either upon app launch or user login
    /// this is an asynchronous call
    func subscribeToRecord(database: CKDatabase, subscriptionID: String, dynamicRecordType: String) {
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let subscription = CKQuerySubscription(recordType: dynamicRecordType,
                                               predicate: predicate,
                                               options: [.firesOnRecordUpdate, .firesOnRecordCreation, .firesOnRecordDeletion])
        // setup notification type
        let notificationInfo = CKNotificationInfo()
        notificationInfo.shouldSendContentAvailable = true // this is a silent push
        subscription.notificationInfo = notificationInfo
        database.save(subscription) { (subscription: CKSubscription?, err: Error?) in
            if err != nil {
                if let ckError = err as? CKError {
                    self.delegate?.ckErrorHandler(error: ckError)
                } else {
                    print("failed to downcast Error to CKError")
                }
            } else {
                self.isSubscriptionLocallyCached = true
                self.delegate?.didSubscribed(subscription: subscription)
            }
        }
    }
    
    /// optional: unsubscribe to database can be an option provided at the Settings viewController
    func unsubscribeToRecord(database: CKDatabase, subscriptionID: String) {
        database.delete(withSubscriptionID: subscriptionID) { (result: String?, err: Error?) in
            if err != nil {
                if let ckError = err as? CKError {
                    self.delegate?.ckErrorHandler(error: ckError)
                } else {
                    print("failed to downcast Error to CKError")
                }
            } else {
                self.isSubscriptionLocallyCached = false
                self.delegate?.didUnsubscribed(result: result)
            }
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
        database.save(payloadRecord) { (record: CKRecord?, err: Error?) in
            if err != nil {
                if let ckError = err as? CKError {
                    self.delegate?.ckErrorHandler(error: ckError)
                } else {
                    print("failed to downcast Error to CKError")
                }
            } else {
                self.delegate?.didCreateRecord(ckRecord: record)
            }
        }
    }
    
    func updateCKRecord(in database: CKDatabase, dataToSend: [String : Bool]?, dynamicRecordType: String) {
        let payloadRecord = CKRecord(recordType: dynamicRecordType)
        if let data = dataToSend {
            payloadRecord.setValuesForKeys(data)
            print(payloadRecord)
        } else {
            print("createCKRecord: - payload is nil")
        }
        database.save(payloadRecord) { (record: CKRecord?, err: Error?) in
            if err != nil {
                if let ckError = err as? CKError {
                    self.delegate?.ckErrorHandler(error: ckError)
                } else {
                    print("failed to downcast Error to CKError")
                }
            } else {
                self.delegate?.didCreateRecord(ckRecord: record)
            }
        }
    }
    
    // called after didReadMessage()
    func deleteCKRecord() {
        delegate?.didDeleteRecord()
    }
    
    // MARK: - Notification
    
    /// Configure a silent remote notification at AppDelegate
    func registerForRemoteCKNotification(with application: UIApplication, completion: (CKNotificationInfo) -> Void) {
        let notificationInfo = CKNotificationInfo()
        notificationInfo.shouldSendContentAvailable = true //  I am not alerting the user in anyway, so no need to request for authorization
        application.registerForRemoteNotifications()
        completion(notificationInfo)
    }
    
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
            // ignore
        } else {
            NotificationCenter.default.removeObserver(observer, name: Notification.Name(CloudKitNotifications.NotificationReceived), object: nil)
        }
    }
    
    // MARK: - Error handler
    
    func retryAfterError(target: Any, error: NSError?, withSelector selector: Selector) {
        if let retryInterval = error?.userInfo[CKErrorRetryAfterKey] as? TimeInterval {
            DispatchQueue.main.async {
                Timer.scheduledTimer(
                    timeInterval: retryInterval,
                    target: target,
                    selector: selector,
                    userInfo: nil,
                    repeats: false)
            }
        }
    }

}

































