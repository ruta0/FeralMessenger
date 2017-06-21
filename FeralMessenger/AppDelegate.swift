//
//  AppDelegate.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/20/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import UserNotifications
import Locksmith


var isParseInitialized: Bool = false
var isSudoGranted: Bool = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var mpcManager: MPCManager!
    var ckManager: CloudKitManager?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        registerForAPNS(with: application)
        CoreDataManager.emptyPersistentContainer() // [development]
        setupMPCManager()
        setupCKManager()
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        ckManager?.resetBadgeCount()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        ckManager?.resetBadgeCount()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        CoreDataManager.saveContext()
    }

}


// MARK: - APNS

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func setupCKManager() {
        ckManager = CloudKitManager()
    }
    
    // listen and post notification for other viewcontrollers to handle
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        ckManager?.postNotifications(userInfo: userInfo, object: self)
    }
    
    // called when received a notification while in background, and launches via notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
//        print("User info =", response.notification.request.content.userInfo)
//        let userInfo = response.notification.request.content.userInfo
//        ckManager?.setupNotifications(userInfo: userInfo, object: self)
        // start from the notification tab
        completionHandler()
    }
    
    // called when a notification is delivered to a foreground app
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
//        let userInfo = notification.request.content.userInfo
//        ckManager?.setupNotifications(userInfo: userInfo, object: self)
        
        completionHandler([.sound])
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


// MARK: - MPC

extension AppDelegate {
    
    func setupMPCManager() {
        mpcManager = MPCManager()
    }
    
}























