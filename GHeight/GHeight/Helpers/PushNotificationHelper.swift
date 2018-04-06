//
//  PushNotificationHelper.swift
//  BeaverRuler
//
//  Created by user on 9/28/17.
//  Copyright © 2017 Sasha. All rights reserved.
//

import UIKit
import Crashlytics
import OneSignal

let AP_APP_PUSH_NOTIFICATION_SHOWN = "com.gittielabs.push_notifacation_shown"

@objc public class PushNotificationHelper: NSObject {
    var application: UIApplication!
    var userdefaults = UserDefaults()
    let requiredLaunchesBeforePushesProposal = 2
    public var appId: String!
    
    @objc public static var sharedInstance = PushNotificationHelper()
    
    //MARK: - Initialize
    override init() {
        super.init()
        setup()
    }
    
    func setup(){
        NotificationCenter.default.addObserver(self, selector: #selector(PushNotificationHelper.appDidFinishLaunching), name: .UIApplicationDidFinishLaunching, object: nil)
    }
    
    //MARK: - NSNotification Observers
    @objc func appDidFinishLaunching(notification: NSNotification){
        if let _application = notification.object as? UIApplication{
            self.application = _application
            displayRatingsPromptIfRequired()
        }
    }
    
    //MARK: - App Launch count
    func getAppLaunchCount() -> Int {
        let launches = userdefaults.integer(forKey: AP_APP_LAUNCHES)
        return launches
    }
    
    func getFirstLaunchDate()->NSDate{
        if let date = userdefaults.value(forKey: AP_INSTALL_DATE) as? NSDate{
            return date
        }
        
        return NSDate()
    }
    
    //MARK: App Rating Shown
    func setPushNotificationProposalShown(){
        userdefaults.set(true, forKey: AP_APP_PUSH_NOTIFICATION_SHOWN)
        userdefaults.synchronize()
    }
    
    func hasShownPushNotificationProposal()->Bool{
        let shown = userdefaults.bool(forKey: AP_APP_PUSH_NOTIFICATION_SHOWN)
        return shown
    }
    
    //MARK: - Rating the App
    private func displayRatingsPromptIfRequired() {
        if hasShownPushNotificationProposal() == false {
            let appLaunchCount = getAppLaunchCount()
            if appLaunchCount >= self.requiredLaunchesBeforePushesProposal {
                AppAnalyticsHelper.sendAppAnalyticEvent(withName: "Show_push_notification_proposal_Ruler_screen")
                
                OneSignal.promptForPushNotifications(userResponse: { accepted in
                    AppAnalyticsHelper.sendAppAnalyticEvent(withName: "User_accepted_push_notifications_Ruler_screen_\(accepted)")
                })
            }
        }
    }
}
