//
//  SettingsController.swift
//  BeaverRuler
//
//  Created by Aleksandr Khotyashov on 8/22/17.
//  Copyright © 2017 Sasha. All rights reserved.
//

import UIKit

enum Setting: String {
    case measureUnits = "measureUnits"
}

class SettingsController: UIViewController {
    
    @IBOutlet weak var measureUnitsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
