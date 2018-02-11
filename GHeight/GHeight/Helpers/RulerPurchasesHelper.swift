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
//            rulerScreen.apdAdQueue.setMaxAdSize(rulerScreen.capacity)
//            rulerScreen.apdAdQueue.loadAd(of: rulerScreen.type)
        }
        
        rulerScreen.products = []
        RageProducts.store.requestProducts{success, products in
            if success {
                self.rulerScreen.products = products!
            }
        }
    }
    
    func showPurchasesPopUp() {
        let message = NSLocalizedString("purchasesPopUpMessage", comment: "")
        let rateAlert = UIAlertController(title: NSLocalizedString("purchasesPopUpTitle", comment: "") + "\u{1F4B0}", message: message, preferredStyle: .alert)
        let removeAdsPlusLimitAction = UIAlertAction(title: NSLocalizedString("removeAdsPlusLimitButtonTitle", comment: ""), style: .default, handler: { (action) -> Void in
            self.buyProduct(productId: SettingsController.removeAdsPlusLimitProductId)
        })
        
        let removeAdsAction = UIAlertAction(title: NSLocalizedString("removeAdsButtonTitle", comment: ""), style: .default, handler: { (action) -> Void in
            self.buyProduct(productId: SettingsController.removeAdProductId)
        })
        
        let removeLimitAction = UIAlertAction(title: NSLocalizedString("removeLimitButtonTitle", comment: ""), style: .default, handler: { (action) -> Void in
            self.buyProduct(productId: SettingsController.removeUserGalleryProductId)
        })
        
        let restorePurchasesAction = UIAlertAction(title: NSLocalizedString("restorePurchasesButtonTitle", comment: ""), style: .default, handler: { (action) -> Void in
            RageProducts.store.restorePurchases()
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancelKey", comment: ""), style: .cancel, handler: { (action) -> Void in
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
    
}
