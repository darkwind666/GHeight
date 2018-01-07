//
//  RulerScreenshotHelper.swift
//  BeaverRuler
//
//  Created by user on 10/1/17.
//  Copyright © 2017 Sasha. All rights reserved.
//

import Foundation
import UIKit
import Photos
import Photos

class ScreenshotHelper {
    
    var measureScreen: ViewController!
    
    func takeJustScreenshot() {
        
        let takeScreenshotBlock = {
            
            let image = self.measureScreen.sceneView.snapshot()
            
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            DispatchQueue.main.async {
                // Briefly flash the screen.
                let flashOverlay = UIView(frame: self.measureScreen.sceneView.frame)
                flashOverlay.backgroundColor = UIColor.white
                self.measureScreen.sceneView.addSubview(flashOverlay)
                UIView.animate(withDuration: 0.25, animations: {
                    flashOverlay.alpha = 0.0
                }, completion: { _ in
                    flashOverlay.removeFromSuperview()
                })
            }
        }
        
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            takeScreenshotBlock()
        case .restricted, .denied:
            let title = "Denied"
            let message = "Denied"
            showAlert(title: title, message: message)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (authorizationStatus) in
                if authorizationStatus == .authorized {
                    takeScreenshotBlock()
                }
            })
        }
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func showAlert(title: String, message: String, actions: [UIAlertAction]? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let actions = actions {
            for action in actions {
                alertController.addAction(action)
            }
        } else {
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        }
        measureScreen.present(alertController, animated: true, completion: nil)
    }
    
}
