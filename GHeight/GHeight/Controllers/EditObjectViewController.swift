//
//  EditObjectViewController.swift
//  BeaverRuler
//
//  Created by Sasha on 8/26/17.
//  Copyright © 2017 Sasha. All rights reserved.
//

import UIKit
import Photos

protocol EditObjectVCDelegate {
    func reloadObjects()
}

class EditObjectViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var objectNameTextField: UITextField!
    @IBOutlet weak var objectSizeTextField: UITextField!
    @IBOutlet weak var measureUnitLabel: UILabel!

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var compareButton: UIButton!
    
    var measureScreen: ViewController!
    var selectedObjectIndex = 0
    var delegate: EditObjectVCDelegate?
    var unit: DistanceUnit = .centimeter
    fileprivate let imagePicker = UIImagePickerController()
    fileprivate var imageName = ""
    fileprivate var selectedObject: UserObjectRm?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.setTitle(NSLocalizedString("backButtonTitle", comment: ""), for: [])
        saveButton.setTitle(NSLocalizedString("saveButtonTitle", comment: ""), for: [])
        
        compareButton.layer.cornerRadius = 10
        compareButton.layer.borderWidth = 1
        compareButton.layer.borderColor = UIColor.blue.cgColor
        compareButton.setTitle(NSLocalizedString("compareButtonTitle", comment: ""), for: [])
        
        objectNameTextField.delegate = self
        objectSizeTextField.delegate = self
        
        self.imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        let defaults = UserDefaults.standard
        
        let userObjects = GRDatabaseManager.sharedDatabaseManager.grRealm.objects(UserObjectRm.self).sorted(byKeyPath: "createdAt", ascending: false)
        self.selectedObject = userObjects[selectedObjectIndex]
        
        objectNameTextField.text = selectedObject?.name
        
        let objectUnit = DistanceUnit(rawValue: (selectedObject?.sizeUnit!)!)
        let conversionFator = unit.fator / (objectUnit?.fator)!
        objectSizeTextField.text = String(format: "%.2f%", (selectedObject?.height)! * conversionFator)
        
        measureUnitLabel.text = unit.unit
        
        AppAnalyticsHelper.sendAppAnalyticEvent(withName: "edit_object_screen")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        
        AppAnalyticsHelper.sendAppAnalyticEvent(withName: "delete_object_pressed")
        
        try! GRDatabaseManager.sharedDatabaseManager.grRealm.write {
            GRDatabaseManager.sharedDatabaseManager.grRealm.delete(selectedObject!)
            
            if (self.delegate != nil) {
                self.delegate?.reloadObjects()
            }
            
            dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func backPressed(_ sender: Any) {
        AppAnalyticsHelper.sendAppAnalyticEvent(withName: "back_from_edit_object_pressed")
        dismiss(animated: true, completion: nil)
    }
    @IBAction func compareHeightPressed(_ sender: Any) {
        
        AppAnalyticsHelper.sendAppAnalyticEvent(withName: "compare_from_edit_object_pressed")

        if RageProducts.store.isProductPurchased(SettingsController.openFullCelebrityListProductId) || RageProducts.store.isProductPurchased(SettingsController.removeAdsPlusLimitProductId) {
            AppAnalyticsHelper.sendAppAnalyticEvent(withName: "show_celebrity_from_edit_object")
            let height = Float(self.objectSizeTextField.text!)!
            measureScreen.rulerScreenNavigationHelper.showCelebrityListFromRulerMeasureDetail(compareHeight: height, controller: self)

        } else {
            AppAnalyticsHelper.sendAppAnalyticEvent(withName: "show_buy_from_edit_object")
            measureScreen.rulerPurchasesHelper.showBuyFullCelebrityListPopUp(controller: self)
        }
    }
    
    @IBAction func savePressed(_ sender: Any) {
        AppAnalyticsHelper.sendAppAnalyticEvent(withName: "save_object_pressed")
        let userObjects = GRDatabaseManager.sharedDatabaseManager.grRealm.objects(UserObjectRm.self).sorted(byKeyPath: "createdAt", ascending: false)
        let selectedObject = userObjects[selectedObjectIndex]
        
        if objectSizeTextField.text?.characters.count == 0 || (objectNameTextField.text?.characters.count)! == 0 {
            return
        }
        
        if Float(objectSizeTextField.text!) != nil {
            
        } else {
            let alertController = UIAlertController(title: NSLocalizedString("inputError", comment: ""), message:
                NSLocalizedString("inputRightSize", comment: ""), preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("okKey", comment: ""), style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
            return
        }
        
        DispatchQueue.main.async {
            try! GRDatabaseManager.sharedDatabaseManager.grRealm.write({
                selectedObject.name = self.objectNameTextField.text
                selectedObject.height = Float(self.objectSizeTextField.text!)!
                selectedObject.sizeUnit = self.unit.rawValue
                
                if (self.delegate != nil) {
                    self.delegate?.reloadObjects()
                }
            })
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    @IBAction func sharePressed(_ sender: Any) {
        AppAnalyticsHelper.sendAppAnalyticEvent(withName: "share_from_edit_object_pressed")
        let size = objectSizeTextField.text! + " " + unit.unit
        let firstActivityItem = objectNameTextField.text! + " " + size + " #GHeight"
        let secondActivityItem : NSURL = NSURL(string: RateAppHelper.reviewString)!
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [firstActivityItem, secondActivityItem], applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = (sender as! UIButton)
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.unknown
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc
    func dismissCelebritiesList() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        view.endEditing(true)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let imageURL = info[UIImagePickerControllerPHAsset] as? NSURL {
            let result = PHAsset.fetchAssets(withALAssetURLs: [imageURL as URL], options: nil)
            let fileName = result.firstObject?.value(forKey: "filename") as? String ?? "Unknown"
            self.imageName = fileName
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}
