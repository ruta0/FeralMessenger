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
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 25)
        return button
    }()
    
    @IBAction func editButton_tapped(_ sender: UIBarButtonItem) {
        if sender.title == "Save" {
            animateSaveBio()
            updateBioInParse(with: bioTextView.text)
        } else if sender.title == "Edit" {
            animateEditBio()
        }
    }
    
    func beginLoadingAnime() {
        DispatchQueue.main.async {
            self.navigationItem.titleView = self.activityIndicator
            self.activityIndicator.startAnimating()
        }
    }
    
    func stopLoadingAnime() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.navigationItem.titleView = self.titleButton
        }
    }
    
    private func animateEditBio() {
        DispatchQueue.main.async {
            self.editButton.title = "Save"
            self.editButton.tintColor = UIColor.orange
            UIView.animate(withDuration: 1.0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { [weak self] in
                self?.bioTextView.textColor = UIColor.orange
            }) { [weak self] (completed: Bool) in
                if completed {
                    self?.bioTextView.isEditable = true
                }
            }
        }
    }
    
    private func animateSaveBio() {
        DispatchQueue.main.async {
            self.editButton.title = "Edit"
            self.editButton.tintColor = UIColor.white
            UIView.animate(withDuration: 1.0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { [weak self] in
                self?.bioTextView.textColor = UIColor.candyWhite()
            }) { [weak self] (completed: Bool) in
                if completed {
                    self?.bioTextView.isEditable = false
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
    }
    
    // MARK: - Profile section
    
    @IBOutlet weak var profileCell: UITableViewCell!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var bioTextView: UITextView!
    
    func activityIndicatorStopAnime() {
        if activityIndicator.isAnimating {
            DispatchQueue.main.async(execute: {
                self.activityIndicator.stopAnimating()
            })
        }
    }
    
    func activityIndicatorStartAnime() {
        if activityIndicator.isAnimating == false {
            DispatchQueue.main.async(execute: {
                self.activityIndicator.startAnimating()
            })
        }
    }
    
    private func setupProfileSection() {
        // profileCell
        profileCell.backgroundColor = UIColor.mediumBlueGray()
        // warningLabel
        warningLabel.backgroundColor = UIColor.clear
        // avatarButton
        avatarButton.layer.cornerRadius = 36
        avatarButton.layer.borderColor = UIColor.white.cgColor
        avatarButton.layer.borderWidth = 2
        let image = UIImage(named: getCurrentUserAvatarName()!)
        avatarButton.setBackgroundImage(image!, for: UIControlState.normal)
        // usernameLabel
        usernameLabel.backgroundColor = UIColor.clear
        usernameLabel.textColor = UIColor.white
        usernameLabel.text = getCurrentUsernameInParse()
        // dividerView
        dividerView.backgroundColor = UIColor.darkGray
        // bioTextView
        bioTextView.backgroundColor = UIColor.clear
        bioTextView.isEditable = false
        bioTextView.textColor = UIColor.candyWhite()
        bioTextView.textContainerInset = UIEdgeInsets.zero
        bioTextView.textContainer.lineFragmentPadding = 0
        bioTextView.text = getCurrentUserBioInParse()
    }
    
    // MARK: - About section
    
    @IBOutlet weak var termsCell: UITableViewCell!
    @IBOutlet weak var privacyCell: UITableViewCell!
    @IBOutlet weak var termsLabel: UILabel!
    @IBOutlet weak var privacyLabel: UILabel!
    
    private func setupAboutSection() {
        termsLabel.backgroundColor = UIColor.clear
        privacyLabel.backgroundColor = UIColor.clear
    }
    
    // MARK: - Account section
    
    @IBOutlet weak var logoutCell: UITableViewCell!
    @IBOutlet weak var logoutLabel: UILabel!
    @IBOutlet weak var logoutImageView: UIImageView!
    
    @IBAction func logoutButton_tapped(_ sender: UIBarButtonItem) {
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
    
    private func setupAccountSection() {
        logoutCell.backgroundColor = UIColor.mediumBlueGray()
    }
    
    // MARK: - UITableView
    
    private func setupTableView() {
        tableView.sectionIndexColor = UIColor.lightGray
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
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = UIColor.red
        }
    }
    
    // MARK: - Parse
    
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
        let name = PFUser.current()!.username!
        return name
    }
    
    func performLogout() {
        activityIndicatorStartAnime()
        PFUser.logOutInBackground { (error: Error?) in
            self.activityIndicatorStopAnime()
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
        activityIndicatorStartAnime()
        user.saveInBackground { (completed: Bool, error: Error?) in
            self.activityIndicatorStopAnime()
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

































