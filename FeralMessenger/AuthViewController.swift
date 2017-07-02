//
//  AuthViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/21/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import Parse
import Locksmith
import CloudKit


class AuthViewController: AdaptiveScrollViewController, ParseUsersManagerDelegate, CloudKitManagerDelegate {
    
    // MARK: - Lifecycle
    
    private let segueToServerConfigViewController = "SegueToServerConfigViewController"
    
    override func presentServerConfigView(gestureRecognizer: UITapGestureRecognizer) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: self.segueToServerConfigViewController, sender: self)
        }
    }
    
    private let segueToTabBarController = "SegueToTabBarController"
    
    func presentMasterView() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: self.segueToTabBarController, sender: self)
        }
    }
    
    override func redirectToBrowserForTerms() {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(URL.termsUrl!, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(URL.termsUrl!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupParseManager()
        performLogin()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //
    }
    
    // MARK: - Parse
    
    var parseManager: ParseManager?
    
    func setupParseManager() {
        parseManager = ParseManager()
        parseManager?.userDelegate = self
    }
    
    override func performLogin(name: String, pass: String) {
        beginLoadingAnime()
        authButton.isEnabled = false
        parseManager?.attemptToInitializeParse()
        parseManager?.login(user: name, pass: pass)
    }
    
    override func performLogin() {
        KeychainManager.shared.loadAuthToken { (token: String?) in
            guard let token = token else { return }
            self.authButton.isEnabled = false
            self.beginLoadingAnime()
            self.parseManager?.attemptToInitializeParse()
            self.parseManager?.login(token: token)
        }
    }
    
    override func performSignup(name: String, email: String, pass: String) {
        self.authButton.isEnabled = false
        self.beginLoadingAnime()
        self.parseManager?.attemptToInitializeParse()
        parseManager?.signup(with: name, email: email, pass: pass)
    }
    
    func didSignup(completed: Bool, error: Error?) {
        self.authButton.isEnabled = true
        self.endLoadingAnime()
        self.passTextField.text?.removeAll()
        if let err = error {
            self.alertRespond(self.errorLabel, with: [self.nameTextField, self.emailTextField, self.passTextField], for: ResponseType.failure, with: err.localizedDescription)
        } else {
            if completed {
                self.alertRespond(self.errorLabel, with: [self.nameTextField, self.emailTextField, self.passTextField], for: ResponseType.success, with: "Success. Please proceed to login")
            }
        }
    }
    
    func didLogin(pfUser: PFUser?, error: Error?) {
        authButton.isEnabled = true
        passTextField.text?.removeAll()
        endLoadingAnime()
        if error != nil {
            self.alertRespond((self.errorLabel)!, with: [(self.nameTextField)!, (self.passTextField)!], for: ResponseType.failure, with: error!.localizedDescription, completion: {
            })
            KeychainManager.shared.deleteAuthToken(in: KeychainConfiguration.accountType.auth_token.rawValue)
        } else {
            guard let token = pfUser?.sessionToken else { return }
            KeychainManager.shared.persistAuthToken(with: token)
            self.presentMasterView()
        }
    }
    
    // MARK: - CloudKitManagerDelegate
    
    var ckManager: CloudKitManager?
    
    func setupCloudKitManager() {
        ckManager = CloudKitManager()
        ckManager?.delegate = self
    }
    
    func ckErrorHandler(error: CKError) {
        print(error)
    }
    
    func didCreateRecord(ckRecord: CKRecord?, error: Error?) {
        //
    }
    
    func didSubscribed(subscription: CKSubscription?, error: Error?) {
        //
    }
    
}















