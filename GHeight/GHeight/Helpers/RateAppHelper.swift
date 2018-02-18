//
//  RateAppHelper.swift
//  BeaverRuler
//
//  Created by user on 9/17/17.
//  Copyright © 2017 Sasha. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

class RateAppHelper {
    
    static let appID = "1347693469"
    static let reviewString = "https://itunes.apple.com/us/app/id\(appID)?ls=1&mt=8"
    
    static func rateApp() {
        
        if let checkURL = URL(string: reviewString) {
            open(url: checkURL)
        } else {
            print("invalid url")
        }
        
    }
    
    static func open(url: URL) {
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: { (success) in
                print("Open \(url): \(success)")
            })
        } else if UIApplication.shared.openURL(url) {
            print("Open \(url): (success)")
        }
    }
    
}
