//
//  CommonViewController.swift
//  MVVM
//
//  Created by Astghik Hakopian on 8/11/19.
//  Copyright © 2019 Astghik Hakopian. All rights reserved.
//

import UIKit

class CommonViewController: UIViewController {
    
    // MARK: - Public Properties
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadData), for: .valueChanged)
        
        return refreshControl
    }()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        return UIActivityIndicatorView()
    }()
    
    
    // MARK: - Public Properties
    
    var changingConstraint: NSLayoutConstraint? {
        didSet {
//            addKeyboardNotificationObserver()
        }
    }
    
    private var navigationItemTitle: String?
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItemTitle = LocalizationManager.sharedInstance.localize(navigationItem.title ?? "")
        
        configureSettings()
        
        setContent()
        
        reloadData()
        
        addNotificationObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.title = navigationItemTitle
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationItem.title = ""
        view.endEditing(true)
        
        super.viewWillDisappear(animated)
    }
    
    deinit {
        removeNotificationObservers()
    }
    
    
    // MARK: - Configuration
    
    func configureSettings() { }
    
    
    // MARK: - Set Content
    
    func setContent() { }
    
    @objc func reloadData() {
        if activityIndicator.isAnimating {
            refreshControl.endRefreshing()
        }
    }
    
    
    // MARK: - Notifications
    
    func addNotificationObservers() { }
    
    func removeNotificationObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: - Actions
    
    @objc private func endEditingView() {
        view.endEditing(true)
    }
    
    
    // MARK: - Public Methods
    
    // activity indicator
    
    public func setupActivityIndicator(in containerView: UIView? = nil) {
        activityIndicator.frame = view.bounds
        activityIndicator.startAnimating()
        activityIndicator.style = .gray
        
        if containerView != nil {
            containerView!.addSubview(activityIndicator)
        } else {
            view.addSubview(activityIndicator)
        }
    }
    
    public func removeActivityIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.removeFromSuperview()
    }
}
