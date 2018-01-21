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
        
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissSettings))
        settingsViewController.navigationItem.rightBarButtonItem = barButtonItem
        settingsViewController.title = "Gallery"
        
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
    }
    
    func showCelebrityList() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let settingsViewController = storyboard.instantiateViewController(withIdentifier: "CelebrityListViewController") as? CelebrityListViewController else {
            return
        }
        
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissSettings))
        settingsViewController.navigationItem.rightBarButtonItem = barButtonItem
        settingsViewController.title = "Celebrities"
        
        let navigationController = UINavigationController(rootViewController: settingsViewController)
        navigationController.modalPresentationStyle = .popover
        navigationController.popoverPresentationController?.delegate = measureScreen
        navigationController.preferredContentSize = CGSize(width: measureScreen.sceneView.bounds.size.width - 20, height: measureScreen.sceneView.bounds.size.height - 50)
        measureScreen.present(navigationController, animated: true, completion: nil)
        
        navigationController.popoverPresentationController?.sourceView = measureScreen.showCelebrityListButton
        navigationController.popoverPresentationController?.sourceRect = measureScreen.showCelebrityListButton.bounds
    }
    
}
