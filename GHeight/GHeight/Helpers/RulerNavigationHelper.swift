//
//  RulerScreenNavigationHelper.swift
//  BeaverRuler
//
//  Created by user on 9/30/17.
//  Copyright © 2017 Sasha. All rights reserved.
//

import Foundation
import UIKit

class RulerNavigationHelper {
    
    var measureScreen: ViewController!
    
    func showGalleryScreen() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let settingsViewController = storyboard.instantiateViewController(withIdentifier: "ObjectsFoldersViewController") as? ObjectsFoldersViewController else {
            return
        }
        
        settingsViewController.products = measureScreen.products
        settingsViewController.apdAdQueue = measureScreen.apdAdQueue
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissSettings))
        settingsViewController.navigationItem.rightBarButtonItem = barButtonItem
        settingsViewController.title = "Gallery"
        settingsViewController.measureScreen = measureScreen
        settingsViewController.unit = measureScreen.unit
        
        let navigationController = UINavigationController(rootViewController: settingsViewController)
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController?.delegate = measureScreen
        navigationController.preferredContentSize = CGSize(width: measureScreen.sceneView.bounds.size.width - 20, height: measureScreen.sceneView.bounds.size.height - 50)
        measureScreen.present(navigationController, animated: true, completion: nil)
        
        navigationController.popoverPresentationController?.sourceView = measureScreen.galleryButton
        navigationController.popoverPresentationController?.sourceRect = measureScreen.galleryButton.bounds
    }
    
    @objc
    func dismissSettings() {
        measureScreen.dismiss(animated: true, completion: nil)
        updateSettings()
    }
    
    private func updateSettings() {
        measureScreen.updateMeasureUnit()
    }
    
    func showCelebrityListFromRuler(compareHeight: Float) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let settingsViewController = storyboard.instantiateViewController(withIdentifier: "CelebrityListViewController") as? CelebrityListViewController else {
            return
        }
        
        settingsViewController.measureScreen = measureScreen
        
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissSettings))
        settingsViewController.navigationItem.rightBarButtonItem = barButtonItem
        settingsViewController.title = "Celebrities"
        settingsViewController.height = compareHeight
        settingsViewController.unit = measureScreen.unit
        
        let navigationController = UINavigationController(rootViewController: settingsViewController)
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController?.delegate = measureScreen
        navigationController.preferredContentSize = CGSize(width: measureScreen.sceneView.bounds.size.width - 20, height: measureScreen.sceneView.bounds.size.height - 50)
        
        measureScreen.present(navigationController, animated: true, completion: nil)
        
        navigationController.popoverPresentationController?.sourceView = measureScreen.settingsButton
        navigationController.popoverPresentationController?.sourceRect = measureScreen.settingsButton.bounds
    }
    
    func showCelebrityListFromRulerMeasureDetail(compareHeight: Float, controller: EditObjectViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let settingsViewController = storyboard.instantiateViewController(withIdentifier: "CelebrityListViewController") as? CelebrityListViewController else {
            return
        }
        
        settingsViewController.measureScreen = measureScreen
        
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: controller, action: #selector(EditObjectViewController.dismissCelebritiesList))
        settingsViewController.navigationItem.rightBarButtonItem = barButtonItem
        settingsViewController.title = "Celebrities"
        settingsViewController.height = compareHeight
        settingsViewController.unit = measureScreen.unit

        let navigationController = UINavigationController(rootViewController: settingsViewController)
        navigationController.modalPresentationStyle = .overCurrentContext
        navigationController.popoverPresentationController?.delegate = measureScreen
        navigationController.preferredContentSize = CGSize(width: measureScreen.sceneView.bounds.size.width - 20, height: measureScreen.sceneView.bounds.size.height - 50)

        controller.present(navigationController, animated: true, completion: nil)

        navigationController.popoverPresentationController?.sourceView = measureScreen.settingsButton
        navigationController.popoverPresentationController?.sourceRect = measureScreen.settingsButton.bounds
    }
    
    func showSettingsScreen() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let settingsViewController = storyboard.instantiateViewController(withIdentifier: "SettingsController") as? SettingsController else {
            return
        }
        
        settingsViewController.measureScreen = measureScreen
        
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissSettings))
        settingsViewController.navigationItem.rightBarButtonItem = barButtonItem
        settingsViewController.title = "Settings"
        
        let navigationController = UINavigationController(rootViewController: settingsViewController)
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController?.delegate = measureScreen
        navigationController.preferredContentSize = CGSize(width: measureScreen.sceneView.bounds.size.width - 20, height: measureScreen.sceneView.bounds.size.height - 50)
        measureScreen.present(navigationController, animated: true, completion: nil)
        
        navigationController.popoverPresentationController?.sourceView = measureScreen.settingsButton
        navigationController.popoverPresentationController?.sourceRect = measureScreen.settingsButton.bounds
        
    }
    
}
