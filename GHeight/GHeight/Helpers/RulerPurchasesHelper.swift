//
//  RulerPurchasesHelper.swift
//  BeaverRuler
//
//  Created by user on 10/1/17.
//  Copyright © 2017 Sasha. All rights reserved.
//

import Foundation
import UIKit

class RulerPurchasesHelper {
    
    private var rulerScreen: ViewController!
    
    init(rulerScreen: ViewController) {
        
        self.rulerScreen = rulerScreen
        
        NotificationCenter.default.addObserver(self, selector: #selector(RulerPurchasesHelper.handlePurchaseNotification(_:)),
                                               name: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification),
                                               object: nil)
        
        loadInAppsPurchases()
    }
    
    @objc func handlePurchaseNotification(_ notification: Notification) {
        guard let productID = notification.object as? String else { return }
        
        if productID == SettingsController.removeUserGalleryProductId  {
            rulerScreen.removeObjectsLimit = true
        }
        
        if productID == SettingsController.removeAdProductId {
            self.logPurchase(name: "Remove ad", id: productID, price: 1.99)
        }
        
        if productID == SettingsController.removeAdsPlusLimitProductId {
            self.logPurchase(name: "Remove ad and objects limit", id: productID, price: 2.99)
        }
    }
    
    func logPurchase(name: String, id: String, price: NSDecimalNumber) {
    }
    
    func loadInAppsPurchases() {
        if RageProducts.store.isProductPurchased(SettingsController.removeUserGalleryProductId) || RageProducts.store.isProductPurchased(SettingsController.removeAdsPlusLimitProductId) {
            rulerScreen.removeObjectsLimit = true
        }
        
        if (RageProducts.store.isProductPurchased(SettingsController.removeAdProductId)) || (RageProducts.store.isProductPurchased(SettingsController.removeAdsPlusLimitProductId)) {
            
        } else {
            rulerScreen.apdAdQueue.setMaxAdSize(rulerScreen.capacity)
            rulerScreen.apdAdQueue.loadAd(of: rulerScreen.type)
        }
        
        rulerScreen.products = []
        RageProducts.store.requestProducts{success, products in
            if success {
                self.rulerScreen.products = products!
            }
        }
    }
    
    func showPurchasesPopUp() {
        let message = "purchases"
        let rateAlert = UIAlertController(title: "purchases" + "\u{1F4B0}", message: message, preferredStyle: .alert)
        let removeAdsPlusLimitAction = UIAlertAction(title: "remove Ads Plus Limit", style: .default, handler: { (action) -> Void in
            self.buyProduct(productId: SettingsController.removeAdsPlusLimitProductId)
        })
        
        let removeAdsAction = UIAlertAction(title: "remove Ads", style: .default, handler: { (action) -> Void in
            self.buyProduct(productId: SettingsController.removeAdProductId)
        })
        
        let removeLimitAction = UIAlertAction(title: "remove Limit", style: .default, handler: { (action) -> Void in
            self.buyProduct(productId: SettingsController.removeUserGalleryProductId)
        })
        
        let restorePurchasesAction = UIAlertAction(title: "restore Purchases", style: .default, handler: { (action) -> Void in
            RageProducts.store.restorePurchases()
        })
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: { (action) -> Void in
        })
        
        if !RageProducts.store.isProductPurchased(SettingsController.removeAdsPlusLimitProductId) {
            rateAlert.addAction(removeAdsPlusLimitAction)
        }
        
        if !RageProducts.store.isProductPurchased(SettingsController.removeAdProductId){
            rateAlert.addAction(removeAdsAction)
        }
        
        if !RageProducts.store.isProductPurchased(SettingsController.removeUserGalleryProductId) {
            rateAlert.addAction(removeLimitAction)
        }
        
        rateAlert.addAction(restorePurchasesAction)
        rateAlert.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.rulerScreen.present(rateAlert, animated: true, completion: nil)
        }
    }
    
    func buyProduct(productId: String) {
        for (_, product) in rulerScreen.products.enumerated() {
            if product.productIdentifier == productId {
                RageProducts.store.buyProduct(product)
                break
            }
        }
    }
    
    func checkUserLimit() -> Bool {
        
        let userObjects = GRDatabaseManager.sharedDatabaseManager.grRealm.objects(UserObjectRm.self)
        
        if userObjects.count >= rulerScreen.maxObjectsInUserGallery && rulerScreen.removeObjectsLimit == false {
            let objectsLimitTitle = "objects Limit"
            let alertController = UIAlertController(title: "\(objectsLimitTitle) \(rulerScreen.maxObjectsInUserGallery)", message: "do You Whant To Remove Limit ?", preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: "remove Ads Plus Limit Button Title", style: UIAlertActionStyle.default, handler: { UIAlertAction in
                for (_, product) in self.rulerScreen.products.enumerated() {
                    if product.productIdentifier == SettingsController.removeAdsPlusLimitProductId {
                        RageProducts.store.buyProduct(product)
                        break
                    }
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "remove Limit Button Title", style: UIAlertActionStyle.default, handler: { UIAlertAction in
                for (_, product) in self.rulerScreen.products.enumerated() {
                    if product.productIdentifier == SettingsController.removeUserGalleryProductId {
                        RageProducts.store.buyProduct(product)
                        break
                    }
                }
            }))
            
            alertController.addAction(UIAlertAction(title: "make Just Screenshot", style: UIAlertActionStyle.default, handler: { UIAlertAction in
                self.rulerScreen.screenshotHelper.takeJustScreenshot()
            }))
            
            alertController.addAction(UIAlertAction(title: "NO", style: UIAlertActionStyle.default, handler: nil))
            
            rulerScreen.present(alertController, animated: true, completion: nil)
            
            return true
        } else {
            return false
        }
    }
    
}
