//
//  AlertContainerDelegate.swift
//  MVVM
//
//  Created by Astghik Hakopian on 8/11/19.
//  Copyright © 2019 Astghik Hakopian. All rights reserved.
//

import UIKit

struct AlertAction {
    let buttonTitle: String
    let handler: (() -> Void)?
    let style: UIAlertAction.Style = .default
}

struct SingleButtonAlert {
    let title: String
    let message: String
    let action: AlertAction
}


protocol AlertContainerDelegate where Self: UIViewController {
    func present(alert: SingleButtonAlert)
}

extension AlertContainerDelegate {
    func present(alert: SingleButtonAlert) {
        let title = LocalizationManager.sharedInstance.localize(alert.title)
        let message = LocalizationManager.sharedInstance.localize(alert.message)
        let actionTitle = LocalizationManager.sharedInstance.localize(alert.action.buttonTitle)
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: actionTitle, style: alert.action.style, handler: { _ in alert.action.handler?() })
        
        alertController.addAction(alertAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}
