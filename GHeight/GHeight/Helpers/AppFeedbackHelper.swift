//
//  AppFeedbackHelper.swift
//  BeaverRuler
//
//  Created by user on 9/21/17.
//  Copyright © 2017 Sasha. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

@objc public class AppFeedbackHelper: NSObject, MFMailComposeViewControllerDelegate {
    
    static let appFeedbackHelperNotificationKey = "AppFeedbackHelperNotification"
    
    func showFeedback() {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            DispatchQueue.main.async {
                let window = UIApplication.shared.windows[0]
                
                if let presentedViewController = window.rootViewController?.presentedViewController {
                    presentedViewController.present(mailComposeViewController, animated: true, completion: nil)
                } else {
                    window.rootViewController?.present(mailComposeViewController, animated: false, completion: nil)
                }
            }
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["darkwinddev@gmail.com"])
        mailComposerVC.setSubject("GHeight Feedback/Suggestion")
        mailComposerVC.setMessageBody("Please Enter your message here", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
        
        NotificationCenter.default.post(name:Notification.Name(rawValue: AppFeedbackHelper.appFeedbackHelperNotificationKey),
                object: nil,
                userInfo: [:])
        
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        NotificationCenter.default.post(name:Notification.Name(rawValue: AppFeedbackHelper.appFeedbackHelperNotificationKey),
                                        object: nil,
                                        userInfo: [:])
        controller.dismiss(animated: true)
    }
}
