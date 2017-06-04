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
import CoreData


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        isParseInitialized = false
        registerForAPNS(application: application)
        // In order to be in sync with what I have in the database, I need to empty the database on start. Note: I can afford to do this because this app is currently only a pure text messenger.
        CoreDataManager.emptyPersistentContainer()
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
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // implement this
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // fetch notification in the background
        UNUserNotificationCenter.current().getNotificationSettings { (settings: UNNotificationSettings) in
            switch settings.soundSetting {
            case .enabled:
                print("enabled sound setting")
            case .disabled:
                print("disable sound setting")
            case .notSupported:
                print("not supported")
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        // persist token to backend
        // persist token to UserDefault
        UserDefaults.standard.set(deviceTokenString, forKey: "apns_token")
        let apns_token = UserDefaults.standard.string(forKey: "apns_token")
        print(apns_token!)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: ", error)
    }
    
    func registerForAPNS(application: UIApplication) {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted: Bool, error: Error?) in
            if error != nil {
                print(error!.localizedDescription)
            } else if granted {
                application.registerForRemoteNotifications()
            }
        }
    }
    
    func scheduleLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = NSString.localizedUserNotificationString(forKey: "hello_title", arguments: nil)
        content.body = NSString.localizedUserNotificationString(forKey: "hello_body", arguments: nil)
        // deliver the notification in 10 seconds
        content.sound = UNNotificationSound.default()
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "tenseconds", content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: nil)
    }
    
}


// MARK: - Parse lifecycle

extension AppDelegate {
    
    func attemptToInitializeParse() {
        if isParseInitialized == false {
            Parse.initialize(with: ParseConfig.config)
            isParseInitialized = true
        } else {
            // Parse has already been initialized
        }
    }
    
}


















