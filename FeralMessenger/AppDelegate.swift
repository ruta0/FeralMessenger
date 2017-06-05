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
        application.applicationIconBadgeNumber = 0 // clears the badge on app launch
        
        // check if this app is launch via notification
        if let notification = launchOptions?[UIApplicationLaunchOptionsKey.remoteNotification] as? [String : AnyObject] {
            let aps = notification["aps"] as? [String : AnyObject]
            // parse and create the APNS item
            let titleAndBody = createNewAPNSItemInNotificationsMVC(aps: aps)
            print(titleAndBody)
            // add an new item in notificationViewController in the background
            // add a badge to the tabbar
        }
        
        checkOrRegisterForAPNS(application: application)
        CoreDataManager.emptyPersistentContainer() // In order to be in sync with what I have in the database, I need to empty the database on start. Note: I can afford to do this because this app is currently only a pure text messenger. [development]
        
        
        
        
        
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
            
        }
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // user granted for apns
        if application.currentUserNotificationSettings?.types != .none {
            checkOrInstallAPNSInParse(with: deviceToken)
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register APNS: ", error.localizedDescription)
    }
    
    func checkOrRegisterForAPNS(application: UIApplication) {
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
    
    fileprivate func createNewAPNSItemInNotificationsMVC(aps: [String : AnyObject]?) -> (String, String) {
        let alert = aps?["alert"] as? [String : AnyObject]
        let title = alert?["title"] as? String
        let body = alert?["body"] as? String
        return (title ?? "Feral Messenger", body ?? "You have received a notification")
    }
    
    private func checkOrPersistAPNS(with deviceToken: String) {
        if let apns_token = UserDefaults.standard.string(forKey: "apns_token") {
            print("APNS devicetoken have been created in parse and persisted locally for key == apns_token: ", apns_token)
        } else {
            UserDefaults.standard.set(deviceToken, forKey: "apns_token")
        }
    }
    
    fileprivate func checkOrInstallAPNSInParse(with deviceToken: Data) {
        if let installation = PFInstallation.current(), installation.deviceToken == nil {
            installation.setDeviceTokenFrom(deviceToken)
            installation.saveInBackground(block: { [weak self] (completed: Bool, error: Error?) in
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    if completed {
                        self?.checkOrPersistAPNS(with: (installation.deviceToken)!)
                    }
                }
            })
        } else {
            // already registered apns to Parse. No need to do it again.
            print("APNS deviceToken already registered: ", PFInstallation.current()!.deviceToken!)
        }
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













