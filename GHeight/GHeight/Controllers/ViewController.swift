//
//  ViewController.swift
//  GHeight
//
//  Created by user on 12/12/17.
//  Copyright © 2017 user. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import StoreKit
import Appodeal

class HeightMeasure {
    var line: RulerLine?
    var length = Float(0.0)
}

class ViewController: UIViewController {
    
    let maxObjectsInUserGallery = 3

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var showCelebrityListButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var saveHeightButton: UIButton!
    
    @IBOutlet weak var findSurfaceView: UIView!
    @IBOutlet weak var findSurfaceLabel: UILabel!
    
    @IBOutlet weak var goCloserToSurfaceView: UIView!
    @IBOutlet weak var goCloserToSurfaceLabel: UILabel!
    @IBOutlet weak var goCloserProgress: UIProgressView!
    
    fileprivate lazy var session = ARSession()
    fileprivate lazy var sessionConfiguration = ARWorldTrackingConfiguration()
    fileprivate var planeExist = false
    
    let measureTime = Double(1)
    var timer = Timer()
    var lowestPlane: SCNNode?
    
    var unit: DistanceUnit!
    var measurements = [SCNVector3]()
    var startMeasurement = false
    var heightLength = Float(0.0)
    
    var arHelper = ARHelper()
    var screenshotHelper = ScreenshotHelper()
    var rulerScreenNavigationHelper = RulerNavigationHelper()
    var rulerPurchasesHelper: RulerPurchasesHelper!
    
    var removeObjectsLimit = false
    var products = [SKProduct]()
    
    var apdAdQueue : APDNativeAdQueue = APDNativeAdQueue()
    var capacity : Int = 9
    var type : APDNativeAdType = .auto
    var showUserInterstitial = false
    
    var goCloserToSurfaceTimer = Timer()
    let goCloserToSurfaceTimerInterval = Double(0.1)
    let minCloserDistanceToSurface = Float(0.2)
    let maxCloserDistanceToSurface = Float(1.6)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showCelebrityListButton.isHidden = true
        saveHeightButton.isHidden = true
        galleryButton.isHidden = true
        goCloserToSurfaceView.isHidden = true
        
        findSurfaceLabel.text = "Find surface"
        goCloserToSurfaceLabel.text = "Go closer to surface"
        
        goCloserProgress.progress = 0
        
        let userObjects = GRDatabaseManager.sharedDatabaseManager.grRealm.objects(UserObjectRm.self)
        
        if userObjects.count > 0 {
            galleryButton.isHidden = false
        }
        
        arHelper.measureScreen = self
        screenshotHelper.measureScreen = self
        rulerScreenNavigationHelper.measureScreen = self
        rulerPurchasesHelper = RulerPurchasesHelper(rulerScreen: self)
        
        setupScene()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapGesture))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        unit = DistanceUnit.centimeter
        
        let defaults = UserDefaults.standard
        if let measureString = defaults.string(forKey: Setting.measureUnits.rawValue) {
            self.unit = DistanceUnit(rawValue: measureString)!
        } else {
            self.unit = .centimeter
            defaults.set(DistanceUnit.centimeter.rawValue, forKey: Setting.measureUnits.rawValue)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.handleStartARSessionNotification(_:)),
                                               name: Notification.Name(rawValue:AppFeedbackHelper.appFeedbackHelperNotificationKey),
                                               object: nil)
        
        Appodeal.setInterstitialDelegate(self)
    }
    
    fileprivate func setupScene() {
        sceneView.delegate = self
        sceneView.session = session
        messageLabel.text = "detecting plane"
        session.run(sessionConfiguration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    @objc func handleStartARSessionNotification(_ notification: Notification) {
        session.run(sessionConfiguration)
    }
    
    @objc func tapGesture(sender: UITapGestureRecognizer)
    {
//        if startMeasurement == false {
//            DispatchQueue.main.async { [weak self] in
//                self?.measurements = [SCNVector3]()
//                self?.startMeasurement = true
//                self?.timer = Timer.scheduledTimer(timeInterval: (self?.measureTime)!, target: self,   selector: (#selector(ViewController.finishTimer)), userInfo: nil, repeats: false)
//            }
//        }
    }
    
    @IBAction func showCelebrityListPressed(_ sender: Any) {
        self.rulerScreenNavigationHelper.showCelebrityListFromRuler(compareHeight: heightLength * self.unit.fator)
    }
    
    @IBAction func showSettings(_ sender: Any) {
        
        var blockAd = false
        
        if RageProducts.store.isProductPurchased(SettingsController.removeAdProductId) || RageProducts.store.isProductPurchased(SettingsController.removeAdsPlusLimitProductId) {
            blockAd = true
        }
        
        if showUserInterstitial == false && Appodeal.isReadyForShow(with: AppodealShowStyle.interstitial) && blockAd == false {
            Appodeal.showAd(AppodealShowStyle.interstitial, rootViewController: self)
            showUserInterstitial = true
        } else {
            rulerScreenNavigationHelper.showSettingsScreen()
        }
    }
    
    @IBAction func galleryButtonPressed(_ sender: Any) {
        self.rulerScreenNavigationHelper.showGalleryScreen()
    }
    
    @IBAction func takeScreenshot() {
        self.saveUserHeight()
    }
    
    func saveUserHeight() {
        
        if rulerPurchasesHelper.checkUserLimit() == true {
            return
        }
        
        let date = Date()
        let uuid = String(Int(date.timeIntervalSince1970))
        
        let userObjectRm = UserObjectRm()
        userObjectRm.createdAt = date
        userObjectRm.id = uuid
        userObjectRm.sizeUnit = self.unit.rawValue
        userObjectRm.name = "Object" + uuid
        userObjectRm.height = self.getObjectSize() * self.unit.fator
        
        DispatchQueue.main.async {
            try! GRDatabaseManager.sharedDatabaseManager.grRealm.write({
                GRDatabaseManager.sharedDatabaseManager.grRealm.add(userObjectRm, update:true)
                self.galleryButton.isHidden = false
            })
        }
    }
    
    func getObjectSize() -> Float {
        var height: Float = 0.0
        height = heightLength
        return height
    }
    
    func showMessageLabelForLength(length: Float) {
        let measureText = String(format: "%.2f%@", length * (self.unit.fator), (self.unit.unit))
        messageLabel.text = measureText
    }
    
    func updateMeasureUnit() {
        let defaults = UserDefaults.standard
        self.unit = DistanceUnit(rawValue: defaults.string(forKey: Setting.measureUnits.rawValue)!)!
        showMessageLabelForLength(length: heightLength)
    }
}

// MARK: - UIPopoverPresentationControllerDelegate

extension ViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
        
    }
}

// MARK: - AppodealInterstitialDelegate

extension ViewController: AppodealInterstitialDelegate {
    func interstitialWillPresent(){
        
    }
    
    func interstitialDidDismiss(){
        rulerScreenNavigationHelper.showSettingsScreen()
        session.run(sessionConfiguration)
    }
    
    func interstitialDidClick(){
        
    }
}

// MARK: - ARSCNViewDelegate

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        if lowestPlane == nil {
            
        }
        
        if let lowestPlane = lowestPlane {
            if planeAnchor.center.z < lowestPlane.worldPosition.z {
                let planeNode = createPlaneNode(anchor: planeAnchor)
                node.addChildNode(planeNode)
                self.lowestPlane = planeNode
            }
            
        } else {
            let planeNode = createPlaneNode(anchor: planeAnchor)
            node.addChildNode(planeNode)
            lowestPlane = planeNode
        }
        
        DispatchQueue.main.async {
            self.findSurfaceView.isHidden = true
            self.goCloserToSurfaceView.isHidden = false
            self.goCloserToSurfaceTimer = Timer.scheduledTimer(timeInterval: (self.goCloserToSurfaceTimerInterval), target: self,   selector: (#selector(ViewController.checkDistanceToSurface)), userInfo: nil, repeats: true)
        }
        
    }
    
    @objc func checkDistanceToSurface() {
        
        guard let frame = sceneView.session.currentFrame else {
            return
        }
        
        guard let plane = lowestPlane else {
            return
        }
        
        let cameraPos = SCNVector3.positionFromTransform(frame.camera.transform)
        let distance = cameraPos.distance(from: plane.worldPosition)
        
        if distance <= minCloserDistanceToSurface {
            goCloserProgress.progress = 1
            self.goCloserToSurfaceTimer.invalidate()
            goCloserToSurfaceView.isHidden = true
        } else {
            if distance >= maxCloserDistanceToSurface {
                goCloserProgress.progress = 0
            } else {
                let progress = 100 - ((distance - minCloserDistanceToSurface) * 100) / (maxCloserDistanceToSurface - minCloserDistanceToSurface)
                goCloserProgress.progress = progress / 100
                print(progress)
            }
        }
    }
    
    @objc func finishTimer() {
        
        startMeasurement = false
        
        var sumY = Float(0.0)
        for measure in measurements {
            sumY += measure.y
        }
        
        let avarageY = Float(sumY / Float(measurements.count))
        
        guard let plane = lowestPlane else {
            return
        }
        
        let distance = avarageY - (plane.worldPosition.y)
        heightLength = distance
        
        DispatchQueue.main.async { [weak self] in
            self?.messageLabel.text = String(format: "%.2f%@", distance * (self?.unit.fator)!, (self?.unit.unit)!)
        }
        
        showCelebrityListButton.isHidden = false
        saveHeightButton.isHidden = false
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {

    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if startMeasurement == true {
            
            guard let frame = sceneView.session.currentFrame else {
                return
            }
            
            let cameraPos = SCNVector3.positionFromTransform(frame.camera.transform)
            measurements.append(cameraPos)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        let errorCode = (error as NSError).code
        
        if errorCode == 103 {
            
            let alert = UIAlertController(title: "GHeight Would Like To Access The Camera", message: "please Grant Permission To Use The Camera", preferredStyle: .alert )
            alert.addAction(UIAlertAction(title: "open Settings", style: .cancel) { alert in
                
                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: { (success) in
                })
            })
            present(alert, animated: true, completion: nil)
        }
        
        messageLabel.text = "Error"
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        
    }
    
    func createPlaneNode(anchor: ARPlaneAnchor) -> SCNNode {
        return VirtualPlane(anchor: anchor)
    }
}
