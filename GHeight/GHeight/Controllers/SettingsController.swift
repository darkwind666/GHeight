//
//  SettingsController.swift
//  BeaverRuler
//
//  Created by Aleksandr Khotyashov on 8/22/17.
//  Copyright © 2017 Sasha. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin

enum Setting: String {
    case measureUnits = "measureUnits"
}

class SettingsController: UIViewController {
    
    static let removeAdProductId = "com.darkwind.gHeight.removeAd"
    static let removeUserGalleryProductId = "com.darkwind.gHeight.removeUserGalleryLimit"
    static let removeAdsPlusLimitProductId = "com.darkwind.gHeight.removeAdPlusUserGalleryLimit"
    
    @IBOutlet weak var measureUnitsButton: UIButton!
    @IBOutlet weak var facebookButtonView: UIView!
    var measureScreen: ViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popoverPresentationController?.delegate = self
        
        let loginButton = LoginButton(frame: CGRect(origin: CGPoint(x:0,y:0), size: facebookButtonView.bounds.size) ,readPermissions: [ ReadPermission.publicProfile ])
        
        facebookButtonView.addSubview(loginButton)
        
        setUpButtons()
    }
    
    func setUpButtons() {
        setupButtonStyle(button: measureUnitsButton)
        measureUnitsButton.setTitle("Measure units", for: [])
    }
    
    func setupButtonStyle(button: UIButton) {
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = measureUnitsButton.backgroundColor?.cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginFacebookPressed(_ sender: Any) {
        
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [ ReadPermission.publicProfile ], viewController: self) { (loginResult) in
            switch loginResult {
            case .failed(let error):
                print(error)
            case .cancelled:
                print("User cancelled login.")
            case .success( _, _, _):
                print("Logged in!")
            }
        }
    }

    // MARK: - Users Interactions

    @IBAction func measureUnitPressed(_ sender: Any) {

        let defaults = UserDefaults.standard

        let alertVC = UIAlertController(title: "Settings", message: "Select measure unit", preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: DistanceUnit.centimeter.title, style: .default) { [weak self] _ in
            defaults.set(DistanceUnit.centimeter.rawValue, forKey: Setting.measureUnits.rawValue)
        })
        alertVC.addAction(UIAlertAction(title: DistanceUnit.inch.title, style: .default) { [weak self] _ in
            defaults.set(DistanceUnit.inch.rawValue, forKey: Setting.measureUnits.rawValue)
        })
        alertVC.addAction(UIAlertAction(title: DistanceUnit.meter.title, style: .default) { [weak self] _ in
            defaults.set(DistanceUnit.meter.rawValue, forKey: Setting.measureUnits.rawValue)
        })
        
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }

}

extension SettingsController: UIPopoverPresentationControllerDelegate {
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        measureScreen.updateMeasureUnit()
    }
}
