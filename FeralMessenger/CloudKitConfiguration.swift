//
//  CloudKitConfiguration.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/16/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import CloudKit


extension CKRecord {
    
    var wasCreatedByThisUser: Bool {
        return (creatorUserRecordID == nil) || (creatorUserRecordID?.recordName == "__defaultOwner__")
    }
    
}


// Constants

struct CloudKitNotifications {
    static let NotificationReceived = "iCloudRemoteNotificationReceived"
    static let NotificationKey = "iCloudRemoteNotification"
}

struct Cloud {
    struct Entity {
        static let Messages = "Messages"
    }
    struct Attribute {
        static let Read = false
    }
}
