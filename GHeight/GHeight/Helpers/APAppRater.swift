//
//  APAppRater.swift
//  AppRaterSample
//
//  Created by Keith Elliott on 2/9/16.
//  Copyright © 2016 GittieLabs. All rights reserved.
//

import UIKit
import MessageUI

let AP_APP_LAUNCHES = "com.gittielabs.applaunches"
let AP_APP_LAUNCHES_CHANGED = "com.gittielabs.applaunches.changed"
let AP_INSTALL_DATE = "com.gittielabs.install_date"
let AP_APP_RATING_SHOWN = "com.gittielabs.app_rating_shown"

@objc public class APAppRater: NSObject, UIAlertViewDelegate, MFMailComposeViewControllerDelegate {
    var application: UIApplication!
    var userdefaults = UserDefaults()
    let requiredLaunchesBeforeRating = 2
    public var appId: String!
    let appFeedbackHelper = AppFeedbackHelper()
    var rateAlert = UIAlertController()
    
    @objc public static var sharedInstance = APAppRater()
    
    //MARK: - Initialize
    override init() {
        super.init()
        setup()
    }
    
    func setup(){
        NotificationCenter.default.addObserver(self, selector: #selector(APAppRater.appDidFinishLaunching), name: .UIApplicationDidFinishLaunching, object: nil)
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
    
    func incrementAppLaunches(){
        var launches = userdefaults.integer(forKey: AP_APP_LAUNCHES)
        launches = launches + 1
        userdefaults.set(launches, forKey: AP_APP_LAUNCHES)
        userdefaults.synchronize()
    }
    
    func resetAppLaunches(){
        userdefaults.set(0, forKey: AP_APP_LAUNCHES)
        userdefaults.synchronize()
    }
    
    //MARK: - First Launch Date
    func setFirstLaunchDate(){
        userdefaults.setValue(NSDate(), forKey: AP_INSTALL_DATE)
        userdefaults.synchronize()
    }
    
    func getFirstLaunchDate()->NSDate{
        if let date = userdefaults.value(forKey: AP_INSTALL_DATE) as? NSDate{
            return date
        }
    
        return NSDate()
    }
    
    //MARK: App Rating Shown
    func setAppRatingShown(){
        userdefaults.set(true, forKey: AP_APP_RATING_SHOWN)
        userdefaults.synchronize()
    }
    
    func hasShownAppRating()->Bool{
        let shown = userdefaults.bool(forKey: AP_APP_RATING_SHOWN)
        return shown
    }
    
    //MARK: - Rating the App
    private func displayRatingsPromptIfRequired() {
        
        let appLaunchCount = getAppLaunchCount()
        
        if hasShownAppRating() == false {
            if appLaunchCount >= self.requiredLaunchesBeforeRating {
                self.setAppRatingShown()
                rateTheApp(controller: nil)
            }
        }
        
        incrementAppLaunches()
    }
    
    @available(iOS 8.0, *)
    func rateTheApp(controller: UIViewController?){
        
        let message = "rate App Proposal"
        rateAlert = UIAlertController(title: "rate Us" + "\u{1F44D}", message: message, preferredStyle: .alert)
        let goToItunesAction = UIAlertAction(title: "rate Us", style: .default, handler: { (action) -> Void in
            RateAppHelper.rateApp()
        })
        
        let cancelAction = UIAlertAction(title: "not Now", style: .cancel, handler: { (action) -> Void in
        })
        
        let feedbackAction = UIAlertAction(title: "send Feedback", style: .default, handler: { (action) -> Void in
            self.appFeedbackHelper.showFeedback()
        })
        
        rateAlert.addAction(cancelAction)
        rateAlert.addAction(goToItunesAction)
        rateAlert.addAction(feedbackAction)
        
        DispatchQueue.main.async {
            
            if let actualController = controller {
                actualController.present(self.rateAlert, animated: true, completion: nil)
            } else {
                let window = self.application.windows[0]
                window.rootViewController?.present(self.rateAlert, animated: true, completion: nil)
            }
        }
    }
}
