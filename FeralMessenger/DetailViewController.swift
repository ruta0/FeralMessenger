//
//  DetailViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 5/20/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit
import Parse
import CoreData


private let cellID = "DetailCell"

class DetailViewController: FetchedResultsCollectionViewController {
    
    var container: NSPersistentContainer? = CoreDataStack.persistentContainer {
        didSet { updateCollectionView() }
    }
    
    fileprivate var fetchedResultsController: NSFetchedResultsController<CoreMessage>?
    var bottomConstraint: NSLayoutConstraint?
    var selectedUserName: String?
    var messages = [Message]()
    
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.mediumBlueGray()
        return view
    }()
    
    let topBorderView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.lightGray
        return view
    }()
    
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = UIColor.white
        textField.backgroundColor = UIColor.clear
        textField.attributedPlaceholder = NSAttributedString(string: "Enter message...", attributes: [NSForegroundColorAttributeName: UIColor.lightGray])
        textField.keyboardAppearance = UIKeyboardAppearance.dark
        return textField
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        button.setTitle("Send", for: UIControlState.normal)
        button.backgroundColor = UIColor.clear
        let titleColor = UIColor.white
        button.setTitleColor(titleColor, for: UIControlState.normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(sendMessage), for: UIControlEvents.touchUpInside)
        return button
    }()
    
    func handleKeyboardNotification(notification: Notification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            bottomConstraint?.constant = isKeyboardShowing ? -(keyboardFrame?.height)! : 0
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                if isKeyboardShowing {
                    self.scrollToLastCellItem()
                }
            })
        }
    }
    
    func scrollToLastCellItem() {
        guard let collectionView = collectionView else { return }
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        let lastIndexPath = IndexPath(item: numberOfItems - 1, section: 0)
        if numberOfItems >= 1 {
            collectionView.scrollToItem(at: lastIndexPath, at: UICollectionViewScrollPosition.bottom, animated: true)
        }
    }
    
    private func updateCollectionView() {
        if let context = container?.viewContext, selectedUserName != nil {
            let request: NSFetchRequest<CoreMessage> = CoreMessage.fetchRequest()
            let predicate = NSPredicate(format: "receiver_name == %@ AND sender_name == %@", selectedUserName!, (PFUser.current()?.username!)!)
            let inversePredicate = NSPredicate(format: "receiver_name == %@ AND sender_name == %@", (PFUser.current()?.username!)!, selectedUserName!)
            let compoundedPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate, inversePredicate])
            request.sortDescriptors = [NSSortDescriptor(key: "created_at", ascending: true, selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))]
            request.predicate = compoundedPredicate
            fetchedResultsController = NSFetchedResultsController<CoreMessage>(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController?.delegate = self
            do {
                try fetchedResultsController?.performFetch()
            } catch let err {
                print("performFetch failed to fetch: - \(err)")
            }
            collectionView?.reloadData()
        }
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private func setupInputComponent() {
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        messageInputContainerView.addSubview(topBorderView)
        messageInputContainerView.addConstraintsWithFormat(format: "H:|-8-[v0][v1(60)]|", views: inputTextField, sendButton)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: inputTextField)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0]|", views: sendButton)
        messageInputContainerView.addConstraintsWithFormat(format: "H:|[v0]|", views: topBorderView)
        messageInputContainerView.addConstraintsWithFormat(format: "V:|[v0(1)]", views: topBorderView)
    }
    
    private func setupMessageInputContainerView() {
        view.addSubview(messageInputContainerView)
        view.addConstraintsWithFormat(format: "H:|[v0]|", views: messageInputContainerView)
        view.addConstraintsWithFormat(format: "V:[v0(48)]", views: messageInputContainerView)
        bottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
        setupInputComponent()
    }
    
    private func setupTabBar() {
        guard let tabBar = tabBarController?.tabBar else { return }
        tabBar.isHidden = true
    }
    
    private func setupNavigationController() {
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 64, height: 32))
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.text = selectedUserName!
        titleLabel.textColor = UIColor.white
        self.navigationItem.titleView = titleLabel
    }
    
    private func setupCollectionView() {
        self.collectionView?.backgroundColor = UIColor.midNightBlack()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupCollectionView()
        setupMessageInputContainerView()
        setupKeyboardNotifications()
        setupTextFieldDelegate()
        setupCollectionViewGesture()
        setupNavigationController()
        fetchMessages(receiverName: selectedUserName!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        scrollToLastCellItem()
    }
    
}


// MARK: - UICollectionViewDelegateFlowLayout

extension DetailViewController: UICollectionViewDelegateFlowLayout {
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionViewLayout.invalidateLayout()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let messageText = messages[indexPath.item].sms {
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)], context: nil)
            return CGSize(width: view.frame.width, height: estimatedFrame.height+20)
        }
        return CGSize(width: view.frame.width, height: 84)
    }
    
}


// MARK: - UICollectionViewDataSource  + NSFetchedResultsController

extension DetailViewController {
    
    /// Note: notice that there is a footer in the storyboard to offer the additional space offset for the textfield
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellID, for: indexPath) as! DetailCell
        cell.messageTextView.text = messages[indexPath.row].sms
        if let sms = messages[indexPath.item].sms {
            cell.messageTextView.text = sms
            cell.profileImageView.image = #imageLiteral(resourceName: "ProfileImage")
            let size = CGSize(width: 250, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin)
            let estimatedFrame = NSString(string: sms).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14)], context: nil)
            // incoming message
            if messages[indexPath.item].senderName != PFUser.current()!.username! {
                cell.bubbleView.frame = CGRect(x: 8 + 30 + 8, y: 0, width: estimatedFrame.width + 16 + 8, height: estimatedFrame.height + 20)
                cell.messageTextView.frame = CGRect(x: 8 + 30 + 8 + 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                cell.messageTextView.textColor = UIColor.black
                cell.profileImageView.isHidden = false
                cell.bubbleView.backgroundColor = UIColor.lightBlue()
            } else {
                // outgoing message
                cell.bubbleView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 8 - 8, y: 0, width: estimatedFrame.width + 16 + 8, height: estimatedFrame.height + 20)
                cell.messageTextView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
                cell.messageTextView.textColor = UIColor.white
                cell.profileImageView.isHidden = true
                cell.bubbleView.backgroundColor = UIColor.mediumBlueGray()
                cell.messageTextView.textColor = UIColor.white
            }
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionElementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DetailViewFooter", for: indexPath)
            footerView.backgroundColor = UIColor.clear
            return footerView
        default:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DetailViewFooter", for: indexPath)
            footerView.backgroundColor = UIColor.clear
            return footerView
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController!.sections?.count ?? 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sections = fetchedResultsController?.sections, sections.count > 0 {
            return sections[section].numberOfObjects
        } else {
            return 0
        }
    }
    
}


// MARK: - UITextFieldDelegate + UICollectionViewTap

extension DetailViewController: UITextFieldDelegate {
    
    func setupTextFieldDelegate() {
        inputTextField.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputTextField.resignFirstResponder()
        return true
    }
    
    func setupCollectionViewGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(collectionViewTapped(recognizer: )))
        collectionView?.addGestureRecognizer(gesture)
    }
    
    func collectionViewTapped(recognizer: UIGestureRecognizer) {
        inputTextField.resignFirstResponder()
    }
    
}





















