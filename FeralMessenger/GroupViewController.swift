//
//  GroupViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/1/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import Parse
import Locksmith


class GroupViewController: UITableViewController {
    
    // MARK: - NavigationController
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        view.hidesWhenStopped = true
        return view
    }()
    
    lazy var titleButton: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor.white
        button.setTitle("Settings", for: UIControlState.normal)
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 25)
        return button
    }()
    
    @IBAction func editButton_tapped(_ sender: UIBarButtonItem) {
        if sender.title == "Save" {
            animateToEditMode()
            updateBioInParse(with: bioTextView.text)
        } else if sender.title == "Edit" {
            animateToSaveMode()
        }
    }
    
    func beginLoadingAnime() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            self.navigationItem.titleView = self.activityIndicator
        }
    }
    
    func stopLoadingAnime() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.navigationItem.titleView = self.titleButton
        }
    }
    
    // from "Edit" to "Save"
    private func animateToSaveMode() {
        DispatchQueue.main.async {
            self.editButton.title = "Save"
            self.editButton.tintColor = UIColor.orange
            UIView.animate(withDuration: 1.0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.bioTextView.textColor = UIColor.orange
            }) { (completed: Bool) in
                if completed {
                    self.bioTextView.isEditable = true
                }
            }
        }
    }
    
    // from "Save" to "Edit"
    private func animateToEditMode() {
        DispatchQueue.main.async {
            self.editButton.title = "Edit"
            UIView.animate(withDuration: 1.0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.bioTextView.textColor = UIColor.candyWhite()
            }) { (completed: Bool) in
                if completed {
                    self.bioTextView.isEditable = false
                }
            }
        }
    }
    
    private func setupNavigationController() {
        guard let navigationController = navigationController else { return }
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.barTintColor = UIColor.mediumBlueGray()
        navigationController.navigationBar.tintColor = UIColor.white
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        navigationItem.titleView = titleButton
        editButton.tintColor = UIColor.orange
    }
    
    // MARK: - Profile section
    
    @IBOutlet weak var profileCell: UITableViewCell!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var bioTextView: UITextView!
    
    private func setupProfileSection() {
        // profileCell
        profileCell.backgroundColor = UIColor.mediumBlueGray()
        // warningLabel
        warningLabel.backgroundColor = UIColor.clear
        warningLabel.isHidden = true
        // avatarButton
        avatarButton.layer.cornerRadius = 36
        avatarButton.layer.borderColor = UIColor.white.cgColor
        avatarButton.layer.borderWidth = 2
        // usernameLabel
        userLabel.backgroundColor = UIColor.clear
        userLabel.textColor = UIColor.white
        // dividerView
        dividerView.backgroundColor = UIColor.lightGray
        // bioTextView
        bioTextView.backgroundColor = UIColor.clear
        bioTextView.isEditable = false
        bioTextView.textColor = UIColor.candyWhite()
        bioTextView.textContainerInset = UIEdgeInsets.zero
        bioTextView.textContainer.lineFragmentPadding = 0
    }
    
    // MARK: - About section
    
    @IBOutlet weak var termsCell: UITableViewCell!
    @IBOutlet weak var privacyCell: UITableViewCell!
    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var privacyLabel: UILabel!
    
    private func setupAboutSection() {
        // termsCell
        termsCell.backgroundColor = UIColor.mediumBlueGray()
        termsCell.contentView.backgroundColor = UIColor.clear
        termsLabel.backgroundColor = UIColor.clear
        termsLabel.textColor = UIColor.white
        // privacyCell
        privacyCell.backgroundColor = UIColor.mediumBlueGray()
        privacyCell.contentView.backgroundColor = UIColor.clear
        privacyLabel.backgroundColor = UIColor.clear
        privacyLabel.textColor = UIColor.white
    }
    
    // MARK: - Account section
    
    @IBOutlet weak var logoutCell: UITableViewCell!
    @IBOutlet weak var logoutLabel: UILabel!
    
    func presentLogoutAlertView() {
        let alert = UIAlertController(title: "What would you like to do?", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        let logout = UIAlertAction(title: "Logout", style: UIAlertActionStyle.destructive) { (action: UIAlertAction) in
            self.performLogout()
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(logout)
        alert.addAction(cancel)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func setupAccountSection() {
        // logoutCell
        logoutCell.backgroundColor = UIColor.darkGray
        logoutCell.contentView.backgroundColor = UIColor.clear
        // logoutTitleLabel
        logoutLabel.backgroundColor = UIColor.clear
        logoutLabel.textColor = UIColor.white
    }
    
    // MARK: - UITableView
    
    private func setupTableView() {
        tableView.backgroundColor = UIColor.midNightBlack()
        tableView.sectionIndexColor = UIColor.mediumBlueGray()
    }
    
    // MARK: - TabBarController
    
    private func setupTabBar() {
        guard let tabBar = tabBarController?.tabBar else { return }
        tabBar.tintColor = UIColor.candyWhite()
        tabBar.barTintColor = UIColor.midNightBlack()
        tabBar.isHidden = false
        tabBar.isTranslucent = false
    }
    
    // MARK: - Lifecycle

    func dismissTabBar() {
        DispatchQueue.main.async {
            self.tabBarController?.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupTabBar()
        setupNavigationController()
        setupProfileSection()
        setupAboutSection()
        setupAccountSection()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateAvatar()
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                termsCell.backgroundColor = UIColor.miamiBlue()
            } else {
                privacyCell.backgroundColor = UIColor.miamiBlue()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            if indexPath.row == 0 {
                termsCell.backgroundColor = UIColor.mediumBlueGray()
            } else {
                privacyCell.backgroundColor = UIColor.mediumBlueGray()
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // bad bad idea, I must fix this later
        if indexPath.section == 1 {
            print(123)
        } else if indexPath.section == 2 {
            presentLogoutAlertView()
        }
    }
    
    // MARK: - Parse
    
    var currentUser: PFUser {
        return PFUser.current()!
    }
    
    func updateAvatar() {
        DispatchQueue.main.async {
            self.avatarButton.setBackgroundImage(UIImage(named: self.getCurrentUserAvatarName()!), for: UIControlState.normal)
        }
    }
    
    func getCurrentUserAvatarName() -> String? {
        if let name = PFUser.current()?["avatar"] as? String {
            return name
        } else {
            return nil
        }
    }
    
    func getCurrentUserBioInParse() -> String? {
        let bio = PFUser.current()?["bio"] as? String
        return bio
    }
    
    func getCurrentUsernameInParse() -> String {
        let name = currentUser.username!
        return name
    }
    
    func performLogout() {
        PFUser.logOutInBackground { (error: Error?) in
            self.removeAuthTokenInKeychain(account: KeychainConfiguration.accountType.auth_token.rawValue)
            if error != nil {
                self.alertRespond((self.warningLabel)!, with: nil, for: ResponseType.failure, with: error!.localizedDescription, completion: nil)
            } else {
                self.dismissTabBar()
            }
        }
    }
    
    func updateBioInParse(with newBio: String?) {
        guard let newBio = newBio, let user = PFUser.current() else { return }
        user["bio"] = newBio
        user.saveInBackground { (completed: Bool, error: Error?) in
            if error != nil {
                self.alertRespond((self.warningLabel)!, with: nil, for: ResponseType.failure, with: error!.localizedDescription, completion: nil)
            } else {
                if completed == true {
                    self.alertRespond((self.warningLabel)!, with: nil, for: ResponseType.success, with: "Saved", completion: nil)
                }
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

}

































