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
            if let err = error {
                self.scheduleNavigationPrompt(with: err.localizedDescription, duration: 4)
            } else {
                if completed {
                    self.scheduleNavigationPrompt(with: "Updated successfully", duration: 4)
                }
            }
        }
    }
    
    override func performLogout() {
        beginLoadingAnime()
        PFUser.logOutInBackground { (error: Error?) in
            self.endLoadingAnime()
            self.removeAuthTokenInKeychain(account: KeychainConfiguration.accountType.auth_token.rawValue)
            if let err = error {
                self.scheduleNavigationPrompt(with: err.localizedDescription, duration: 4)
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
            scheduleNavigationPrompt(with: err.localizedDescription, duration: 4)
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
    private let segueToAvatarViewController = "SegueToAvatarViewController"
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueToTermsWebViewController || segue.identifier == segueToPrivacyWebViewController {
            guard let webViewController = segue.destination as? WebViewController else {
                print("Unexpected sender of cell: ", segue.identifier!)
                return
            }
            webViewController.link = URL.termsUrl
        } else if segue.identifier == segueToAvatarViewController {
            // ignore for now...
        }
    }
    
}
