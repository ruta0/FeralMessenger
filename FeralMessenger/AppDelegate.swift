//
//  AppDelegate.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/20/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import UserNotifications
import Parse
import Locksmith


var isParseInitialized: Bool = false
var isSudoGranted: Bool = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var mpcManager: MPCManager!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        application.applicationIconBadgeNumber = 0 // clears the badge on app launch
        registerForAPNS(with: application)
        // CoreDataManager.emptyPersistentContainer() // [development]
        setupMPCManager()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        Secret.shared.setupSecret()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataManager.saveContext()
    }

}


// MARK: - APNS

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // called when received a notification while in background, and launches via notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // clears the badge only when the user actually taps on the cell, not here
        print("User info =", response.notification.request.content.userInfo)
        // implement this
        // start from the notification tab
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // clears the badge only when the user actually taps on the cell, not here. if users is already talking to the user, then there is no need for this.
        // called when a notification is delivered to a foreground app
        // add a badge to the tabbar notification tab
        // implement this
        print("User info = ", notification.request.content.userInfo)
        completionHandler([.sound])
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // fetch notification in the background from death
        let aps = userInfo["aps"] as! [String : AnyObject]
        if (aps["content-available"] as? NSString)?.integerValue == 1 {
            // implement this!
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // user granted for apns
        if application.currentUserNotificationSettings?.types != .none {
            ParseServerManager.shared.saveDeviceToken(with: deviceToken, completion: { (completed: Bool) in
                if completed {
                    KeychainManager.shared.persistDeviceToken(with: deviceToken)
                }
            })
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register APNS: ", error.localizedDescription)
    }
    
    func registerForAPNS(with application: UIApplication) {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted: Bool, error: Error?) in
                if error != nil {
                    print(error!.localizedDescription)
                } else if granted {
                    print("APNS granted")
                    application.registerForRemoteNotifications()
                }
            }
        }
    }
    
}


// MARK: - MPC

extension AppDelegate {
    
    func setupMPCManager() {
        mpcManager = MPCManager()
    }
    
}























