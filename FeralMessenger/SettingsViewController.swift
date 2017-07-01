//
//  SettingsViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/30/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import Parse
import Locksmith


class SettingsViewController: GroupViewController {
    
    // MARK: - NaviagationController
    
    override func editButton_tapped(_ sender: UIBarButtonItem) {
        super.editButton_tapped(sender)
        if sender.title == "Save" {
            updateBio(with: bioTextView.text)
        }
    }
    
    // MARK: - Parse
    
    var currentUser: PFUser {
        return PFUser.current()!
    }
    
    func setupBio() {
        guard let bio = currentUser["bio"] as? String else { return }
        bioTextView.text = bio
    }
    
    func setupusername() {
        guard let username = currentUser.username else { return }
        userLabel.text = username
    }
    
    func updateAvatar() {
        guard let currentAvatarName = currentUser["avatar"] as? String else { return }
        guard let updatedImage = UIImage(named: currentAvatarName) else { return }
        DispatchQueue.main.async {
            self.avatarButton.setBackgroundImage(updatedImage, for: UIControlState.normal)
        }
    }
    
    func updateBio(with newBio: String?) {
        guard let newBio = newBio else { return }
        currentUser["bio"] = newBio
        beginLoadingAnime()
        currentUser.saveInBackground { (completed: Bool, error: Error?) in
            self.endLoadingAnime()
            if error != nil {
                self.alertRespond((self.warningLabel)!, with: nil, for: ResponseType.failure, with: error!.localizedDescription, completion: nil)
            } else {
                if completed == true {
                    self.alertRespond((self.warningLabel)!, with: nil, for: ResponseType.success, with: "Saved", completion: nil)
                }
            }
        }
    }
    
    override func performLogout() {
        beginLoadingAnime()
        PFUser.logOutInBackground { (error: Error?) in
            self.endLoadingAnime()
            self.removeAuthTokenInKeychain(account: KeychainConfiguration.accountType.auth_token.rawValue)
            if error != nil {
                self.alertRespond((self.warningLabel)!, with: nil, for: ResponseType.failure, with: error!.localizedDescription, completion: nil)
            } else {
                self.dismissTabBar()
            }
        }
    }
    
    // MARK: - Keychain
    
    private func removeAuthTokenInKeychain(account: String) {
        do {
            try Locksmith.deleteDataForUserAccount(userAccount: KeychainConfiguration.accountType.auth_token.rawValue, inService: KeychainConfiguration.serviceName)
        } catch let err {
            alertRespond(warningLabel, with: nil, for: ResponseType.failure, with: err.localizedDescription, completion: nil)
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBio()
        setupusername()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateAvatar()
    }
    
    private let segueToTermsWebViewController = "SegueToTermsWebViewController"
    private let segueToPrivacyWebViewController = "SegueToPrivacyWebViewController"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let webViewController = segue.destination as? WebViewController else {
            print("Unexpected sender of cell")
            return
        }
        if segue.identifier == segueToTermsWebViewController {
            webViewController.link = URL.termsUrl
        } else if segue.identifier == segueToPrivacyWebViewController {
            webViewController.link = URL.termsUrl
        }
    }
    
}
