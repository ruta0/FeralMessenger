//
//  WebViewController.swift
//  FeralMessenger
//
//  Created by rightmeow on 6/30/17.
//  Copyright © 2017 Duckisburg. All rights reserved.
//

import UIKit


class WebViewController: UIViewController, UIWebViewDelegate {
    
    var link: URL? {
        didSet {
            renderWebView(with: link)
        }
    }
    
    func renderWebView(with link: URL?) {
        guard let hyperLink = link else {
            print("url cannot be nil")
            return
        }
        let request = URLRequest(url: hyperLink)
        DispatchQueue.main.async {
            self.webView.loadRequest(request)
        }
    }
    
    // MARK: - NavigationController
    
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
    
    private func setupNavigationController() {
        guard let navigationController = navigationController else { return }
        navigationController.navigationBar.tintColor = UIColor.white
        navigationItem.titleView = titleButton
    }
    
    // MARK: - UIWebViewDelegate
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        beginLoadingAnime()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        endLoadingAnime()
    }
    
    // MARK: - UIViewController
    
    @IBOutlet weak var webView: UIWebView!
    
    private func setupViews() {
        webView.delegate = self
        webView.backgroundColor = UIColor.midNightBlack
        webView.tintColor = UIColor.midNightBlack
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationController()
    }
    
}
