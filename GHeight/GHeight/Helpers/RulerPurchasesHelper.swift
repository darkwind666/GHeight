//
//  RulerPurchasesHelper.swift
//  BeaverRuler
//
//  Created by user on 10/1/17.
//  Copyright © 2017 Sasha. All rights reserved.
//

import Foundation
import Crashlytics
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
            AppAnalyticsHelper.sendAppAnalyticEvent(withName: "User_buy_objects_limit")
            self.logPurchase(name: "Remove user gallery limit", id: productID, price: 0.99)
        }
        
        if productID == SettingsController.removeAdProductId {
            AppAnalyticsHelper.sendAppAnalyticEvent(withName: "User_buy_remove_ad")
            self.logPurchase(name: "Remove ad", id: productID, price: 0.99)
        }
        
        if productID == SettingsController.removeAdsPlusLimitProductId {
            AppAnalyticsHelper.sendAppAnalyticEvent(withName: "User_buy_full_version")
            self.logPurchase(name: "Buy full version", id: productID, price: 1.99)
        }
        
        if productID == SettingsController.openFullCelebrityListProductId {
            AppAnalyticsHelper.sendAppAnalyticEvent(withName: "User_buy_full_celebrity_list")
            self.logPurchase(name: "Open full celebrity list", id: productID, price: 0.99)
        }
    }
    
    func logPurchase(name: String, id: String, price: NSDecimalNumber) {
        Answers.logPurchase(withPrice: price,
                            currency: "USD",
                            success: true,
                            itemName: name,
                            itemType: "In app",
                            itemId: id,
                            customAttributes: [:])
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
    
    func showRemoveAdsProposalAlert(controller: UIViewController?) {
        
        let alertController = UIAlertController(title: NSLocalizedString("removeAdsButtonTitle", comment: ""), message: NSLocalizedString("purchasesPopUpMessage", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("removeAdsPlusLimitButtonTitle", comment: ""), style: UIAlertActionStyle.default, handler: { UIAlertAction in
            for (_, product) in self.rulerScreen.products.enumerated() {
                if product.productIdentifier == SettingsController.removeAdsPlusLimitProductId {
                    RageProducts.store.buyProduct(product)
                    AppAnalyticsHelper.sendAppAnalyticEvent(withName: "buy_full_version_pressed_remove_ad_proposal")
                    break
                }
            }
        }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("removeAdsButtonTitle", comment: ""), style: UIAlertActionStyle.default, handler: { UIAlertAction in
            for (_, product) in self.rulerScreen.products.enumerated() {
                if product.productIdentifier == SettingsController.removeAdProductId {
                    RageProducts.store.buyProduct(product)
                    AppAnalyticsHelper.sendAppAnalyticEvent(withName: "buy_remove_ad_version_pressed_remove_ad_proposal")
                    break
                }
            }
        }))
        
        alertController.addAction(UIAlertAction(title: NSLocalizedString("noKey", comment: ""), style: UIAlertActionStyle.default, handler: { (action) -> Void in
            AppAnalyticsHelper.sendAppAnalyticEvent(withName: "User_cancel_remove_ad")
        }))
        
        controller?.present(alertController, animated: true, completion: nil)
    }
    
    func showBuyFullCelebrityListPopUp(controller: UIViewController?) {
        let message = NSLocalizedString("purchasesPopUpMessage", comment: "")
        let rateAlert = UIAlertController(title: NSLocalizedString("purchasesPopUpTitle", comment: "") + "\u{1F4B0}", message: message, preferredStyle: .alert)
        
        let removeAdsPlusLimitAction = UIAlertAction(title: NSLocalizedString("removeAdsPlusLimitButtonTitle", comment: ""), style: .default, handler: { (action) -> Void in
            self.buyProduct(productId: SettingsController.removeAdsPlusLimitProductId)
            AppAnalyticsHelper.sendAppAnalyticEvent(withName: "buy_full_version_celebrity_list_pressed")
        })
        
        let openFullCelebrityListAction = UIAlertAction(title: NSLocalizedString("openFullCelebrityListTitle", comment: ""), style: .default, handler: { (action) -> Void in
            self.buyProduct(productId: SettingsController.openFullCelebrityListProductId)
            AppAnalyticsHelper.sendAppAnalyticEvent(withName: "buy_celebrity_list_pressed")
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancelKey", comment: ""), style: .cancel, handler: { (action) -> Void in
            AppAnalyticsHelper.sendAppAnalyticEvent(withName: "User_cancel_buy_celebrity_list")
        })
        
        if !RageProducts.store.isProductPurchased(SettingsController.removeAdsPlusLimitProductId) {
            rateAlert.addAction(removeAdsPlusLimitAction)
        }
        
        if !RageProducts.store.isProductPurchased(SettingsController.openFullCelebrityListProductId) {
            rateAlert.addAction(openFullCelebrityListAction)
        }
        
        rateAlert.addAction(cancelAction)
        
        DispatchQueue.main.async {
            controller?.present(rateAlert, animated: true, completion: nil)
        }
    }
    
    func showPurchasesPopUp(controller: UIViewController?) {
        let message = NSLocalizedString("purchasesPopUpMessage", comment: "")
        let rateAlert = UIAlertController(title: NSLocalizedString("purchasesPopUpTitle", comment: "") + "\u{1F4B0}", message: message, preferredStyle: .alert)
        
        let removeAdsPlusLimitAction = UIAlertAction(title: NSLocalizedString("removeAdsPlusLimitButtonTitle", comment: ""), style: .default, handler: { (action) -> Void in
            self.buyProduct(productId: SettingsController.removeAdsPlusLimitProductId)
            AppAnalyticsHelper.sendAppAnalyticEvent(withName: "Buy_full_version_pressed")
        })
        
        let openFullCelebrityListAction = UIAlertAction(title: NSLocalizedString("openFullCelebrityListTitle", comment: ""), style: .default, handler: { (action) -> Void in
            self.buyProduct(productId: SettingsController.openFullCelebrityListProductId)
            AppAnalyticsHelper.sendAppAnalyticEvent(withName: "Buy_celebrity_list_pressed")
        })
        
        let removeAdsAction = UIAlertAction(title: NSLocalizedString("removeAdsButtonTitle", comment: ""), style: .default, handler: { (action) -> Void in
            self.buyProduct(productId: SettingsController.removeAdProductId)
            AppAnalyticsHelper.sendAppAnalyticEvent(withName: "Buy_remove_ad_pressed")
        })
        
        let removeLimitAction = UIAlertAction(title: NSLocalizedString("removeLimitButtonTitle", comment: ""), style: .default, handler: { (action) -> Void in
            self.buyProduct(productId: SettingsController.removeUserGalleryProductId)
            AppAnalyticsHelper.sendAppAnalyticEvent(withName: "Buy_remove_limit_pressed")
        })
        
        let restorePurchasesAction = UIAlertAction(title: NSLocalizedString("restorePurchasesButtonTitle", comment: ""), style: .default, handler: { (action) -> Void in
            RageProducts.store.restorePurchases()
            AppAnalyticsHelper.sendAppAnalyticEvent(withName: "restore_pressed")
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancelKey", comment: ""), style: .cancel, handler: { (action) -> Void in
            AppAnalyticsHelper.sendAppAnalyticEvent(withName: "User_cancel_buy_from_settings")
        })
        
        if !RageProducts.store.isProductPurchased(SettingsController.removeAdsPlusLimitProductId) {
            rateAlert.addAction(removeAdsPlusLimitAction)
        }
        
        if !RageProducts.store.isProductPurchased(SettingsController.openFullCelebrityListProductId) {
            rateAlert.addAction(openFullCelebrityListAction)
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
            controller?.present(rateAlert, animated: true, completion: nil)
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
            let objectsLimitTitle = NSLocalizedString("objectsLimit", comment: "")
            let alertController = UIAlertController(title: "\(objectsLimitTitle) \(rulerScreen.maxObjectsInUserGallery)", message: NSLocalizedString("purchasesPopUpMessage", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            
            alertController.addAction(UIAlertAction(title: NSLocalizedString("removeAdsPlusLimitButtonTitle", comment: ""), style: UIAlertActionStyle.default, handler: { UIAlertAction in
                for (_, product) in self.rulerScreen.products.enumerated() {
                    if product.productIdentifier == SettingsController.removeAdsPlusLimitProductId {
                        RageProducts.store.buyProduct(product)
                        AppAnalyticsHelper.sendAppAnalyticEvent(withName: "Buy_full_version_from_limit_proposal_pressed")
                        break
                    }
                }
            }))
            
            alertController.addAction(UIAlertAction(title: NSLocalizedString("removeLimitButtonTitle", comment: ""), style: UIAlertActionStyle.default, handler: { UIAlertAction in
                for (_, product) in self.rulerScreen.products.enumerated() {
                    if product.productIdentifier == SettingsController.removeUserGalleryProductId {
                        RageProducts.store.buyProduct(product)
                        AppAnalyticsHelper.sendAppAnalyticEvent(withName: "Buy_remove_limit_from_limit_proposal_pressed")
                        break
                    }
                }
            }))
            
            alertController.addAction(UIAlertAction(title: NSLocalizedString("noKey", comment: ""), style: UIAlertActionStyle.default, handler: { (action) -> Void in
                AppAnalyticsHelper.sendAppAnalyticEvent(withName: "User_cancel_buy_from_limit_proposal")
            }))
            
            rulerScreen.present(alertController, animated: true, completion: nil)
            
            return true
        } else {
            return false
        }
    }
    
}
