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


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        isParseInitialized = false
        registerForAPNS(application: application)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }

}


// MARK: - APNS

extension AppDelegate: UNUserNotificationCenterDelegate {
    
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


















