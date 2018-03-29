//
//  AppAnalyticsHelper.swift
//  BeaverRuler
//
//  Created by Aleksandr Khotyashov on 9/21/17.
//  Copyright © 2017 Sasha. All rights reserved.
//

import Foundation
import Crashlytics
import FacebookCore
import Firebase

class AppAnalyticsHelper {

    static func sendAppAnalyticEvent(withName: String) {
        let newString = withName.replacingOccurrences(of: "_", with: " ", options: .literal, range: nil)
        Answers.logCustomEvent(withName: newString)
        AppEventsLogger.log(withName)
        Analytics.logEvent(withName, parameters: ["name": withName as NSObject])
    }
}
