//
//  GroupViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/1/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit


/// This class comes with a logout button by default, please override the logout method in its subclass
class GroupViewController: UITableViewController, UITextViewDelegate {
    
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
            disableEditMode()
        } else if sender.title == "Edit" {
            enableEditMode()
        }
    }
    
    func beginLoadingAnime() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
            self.navigationItem.titleView = self.activityIndicator
        }
    }
    
    func endLoadingAnime() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.navigationItem.titleView = self.titleButton
        }
    }
    
    func enableEditMode() {
        DispatchQueue.main.async {
            self.editButton.title = "Save"
        }
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.bioTextView.textColor = UIColor.orange
        }) { (completed: Bool) in
            if completed {
                self.bioTextView.isSelectable = true
                self.bioTextView.isEditable = true
                self.bioTextView.becomeFirstResponder()
            }
        }
    }
    
    func disableEditMode() {
        DispatchQueue.main.async {
            self.editButton.title = "Edit"
        }
        UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
            self.bioTextView.textColor = UIColor.candyWhite
        }) { (completed: Bool) in
            if completed {
                self.bioTextView.isSelectable = false
                self.bioTextView.isEditable = false
                self.bioTextView.resignFirstResponder()
            }
        }
    }
    
    var timer: Timer?
    
    func scheduleNavigationPrompt(with message: String, duration: TimeInterval) {
        DispatchQueue.main.async {
            self.navigationItem.prompt = message
            self.timer = Timer.scheduledTimer(timeInterval: duration,
                                         target: self,
                                         selector: #selector(self.removePrompt),
                                         userInfo: nil,
                                         repeats: false)
            self.timer?.tolerance = 5
        }
    }
    
    @objc private func removePrompt() {
        if navigationItem.prompt != nil {
            DispatchQueue.main.async {
                self.navigationItem.prompt = nil
            }
        }
    }
    
    private func setupNavigationController() {
        guard let navigationController = navigationController else { return }
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.barTintColor = UIColor.mediumBlueGray
        navigationController.navigationBar.tintColor = UIColor.white
        navigationItem.titleView = titleButton
        editButton.tintColor = UIColor.orange
        navigationController.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.orange]
    }
    
    // MARK: - Profile section
    
    @IBOutlet weak var profileCell: UITableViewCell!
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var bioTextView: UITextView!
    
    private func setupProfileSection() {
        // profileCell
        profileCell.backgroundColor = UIColor.mediumBlueGray
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
        bioTextView.delegate = self
        bioTextView.backgroundColor = UIColor.clear
        bioTextView.isEditable = false
        bioTextView.isSelectable = false
        bioTextView.textColor = UIColor.candyWhite
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
        termsCell.backgroundColor = UIColor.darkGray
        termsCell.contentView.backgroundColor = UIColor.clear
        termsLabel.backgroundColor = UIColor.clear
        termsLabel.textColor = UIColor.white
        // privacyCell
        privacyCell.backgroundColor = UIColor.darkGray
        privacyCell.contentView.backgroundColor = UIColor.clear
        privacyLabel.backgroundColor = UIColor.clear
        privacyLabel.textColor = UIColor.white
    }
    
    // MARK: - Account section
    
    @IBOutlet weak var logoutCell: UITableViewCell!
    @IBOutlet weak var logoutLabel: UILabel!
    
    func presentLogoutAlertView() {
        let alert = UIAlertController(title: nil, message: "Are you sure your want to logout?", preferredStyle: UIAlertControllerStyle.actionSheet)
        let action = UIAlertAction(title: "Logout", style: UIAlertActionStyle.destructive) { (action: UIAlertAction) in
            self.performLogout()
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alert.addAction(action)
        alert.addAction(cancel)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func performLogout() {
        // override this to implement
    }
    
    private func setupAccountSection() {
        // logoutCell
        logoutCell.backgroundColor = UIColor.darkGray
        logoutCell.contentView.backgroundColor = UIColor.clear
        // logoutTitleLabel
        logoutLabel.backgroundColor = UIColor.clear
        logoutLabel.textColor = UIColor.white
    }
    
    // MARK: - UITableView
    
    private func setupTableView() {
        tableView.backgroundColor = UIColor.midNightBlack
        tableView.sectionIndexColor = UIColor.mediumBlueGray
    }
    
    // MARK: - TabBarController
    
    private func setupTabBar() {
        guard let tabBar = tabBarController?.tabBar else { return }
        tabBar.tintColor = UIColor.candyWhite
        tabBar.barTintColor = UIColor.midNightBlack
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
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableViewAutomaticDimension
        } else {
            return 44
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // bad bad idea, I must fix this later
        if indexPath.section == 2 {
            presentLogoutAlertView()
        }
    }
    
    override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            // ignore
        } else {
            tableView.cellForRow(at: indexPath)?.backgroundColor = UIColor.miamiBlue
        }
    }
    
    override func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            // ignore
        } else {
            tableView.cellForRow(at: indexPath)?.backgroundColor = UIColor.darkGray
        }
    }

}


