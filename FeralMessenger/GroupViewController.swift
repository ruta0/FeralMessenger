//
//  GroupViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/1/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import Parse


class GroupViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var profileContainerView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var dividerView: UIView!
    @IBOutlet weak var bioTextView: UITextView!
    
    @IBAction func logoutButton_tapped(_ sender: UIBarButtonItem) {
        performLogout()
    }
    
    @IBAction func editButton(_ sender: UIBarButtonItem) {
        if sender.title == "Save" {
            animateSaveBio()
            updateBioInParse(with: bioTextView.text)
        } else if sender.title == "Edit" {
            animateEditBio()
        }
    }
    
    private func animateEditBio() {
        DispatchQueue.main.async { [weak self] in
            self?.editButton.title = "Save"
            self?.editButton.tintColor = UIColor.orange
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
        DispatchQueue.main.async { [weak self] in
            self?.editButton.title = "Edit"
            self?.editButton.tintColor = UIColor.white
            UIView.animate(withDuration: 1.0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { [weak self] in
                self?.bioTextView.textColor = UIColor.candyWhite()
            }) { [weak self] (completed: Bool) in
                if completed {
                    self?.bioTextView.isEditable = false
                }
            }
        }
    }
    
    fileprivate func setupTabBar() {
        guard let tabBar = tabBarController?.tabBar else { return }
        tabBar.tintColor = UIColor.candyWhite()
        tabBar.barTintColor = UIColor.midNightBlack()
        tabBar.isHidden = false
        tabBar.isTranslucent = false
    }
    
    fileprivate func setupNavigationController() {
        guard let navigationController = navigationController else { return }
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.barTintColor = UIColor.mediumBlueGray()
        navigationController.navigationBar.tintColor = UIColor.white
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }
    
    fileprivate func setupViews() {
        // view
        view.backgroundColor = UIColor.midNightBlack()
        // scrollView
        scrollView.backgroundColor = UIColor.midNightBlack()
        // contentView
        contentView.backgroundColor = UIColor.midNightBlack()
        // headerView
        headerView.backgroundColor = UIColor.clear
        // headerLabel
        headerLabel.backgroundColor = UIColor.clear
        headerLabel.alpha = 0.0
        // profileContainer
        profileContainerView.backgroundColor = UIColor.mediumBlueGray()
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
        // bioTextView
        bioTextView.backgroundColor = UIColor.clear
        bioTextView.isEditable = false
        bioTextView.textColor = UIColor.candyWhite()
        bioTextView.textContainerInset = UIEdgeInsets.zero
        bioTextView.textContainer.lineFragmentPadding = 0
        bioTextView.text = getCurrentUserBioInParse()
    }

}


// MARK: - Lifecycle

extension GroupViewController {
    
    func dismissTabBar() {
        self.tabBarController?.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupNavigationController()
        setupViews()
    }
    
}


// MARK: - Parse

extension GroupViewController {
    
    func getCurrentUserAvatarName() -> String? {
        if let name = PFUser.current()?["avatar"] as? String {
            return name
        } else {
            return nil
        }
    }
    
    func getCurrentUserBioInParse() -> String? {
        if let bio = PFUser.current()?["bio"] as? String {
            return bio
        } else {
            print("current user bio is nil")
            return nil
        }
    }
    
    func getCurrentUsernameInParse() -> String {
        let name = PFUser.current()!.username!
        return name
    }
    
    func performLogout() {
        self.activityIndicator.startAnimating()
        PFUser.logOutInBackground { [weak self] (error: Error?) in
            self?.activityIndicator.stopAnimating()
            self?.removeTokenFromKeychain()
            if error != nil {
                self?.localTextResponder((self?.headerLabel)!, for: ResponseType.failure, with: error!.localizedDescription, completion: nil)
            } else {
                self?.dismissTabBar()
            }
        }
    }
    
    func updateBioInParse(with newBio: String?) {
        guard let newBio = newBio, let user = PFUser.current() else { return }
        user["bio"] = newBio
        activityIndicator.startAnimating()
        user.saveInBackground { [weak self] (completed: Bool, error: Error?) in
            self?.activityIndicator.stopAnimating()
            if error != nil {
                self?.localTextResponder((self?.headerLabel)!, for: ResponseType.failure, with: (error?.localizedDescription)!, completion: nil)
                return
            } else {
                if completed == true {
                    self?.localTextResponder((self?.headerLabel)!, for: ResponseType.success, with: "Saved", completion: nil)
                }
            }
        }
    }
    
}


// MARK: - Keychain

extension GroupViewController {
    
    func removeTokenFromKeychain() {
        let item = KeychainItem(service: KeychainConfiguration.serviceName, account: "auth_token", accessGroup: KeychainConfiguration.accessGroup)
        do {
            try item.deleteItem()
        } catch let err {
            localTextResponder(headerLabel, for: ResponseType.failure, with: err.localizedDescription, completion: nil)
        }
    }
    
}


































