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
import AudioToolbox
import AVFoundation

class HeightMeasure {
    var line: RulerLine?
    var length = Float(0.0)
}

class ViewController: UIViewController {
    
    let maxObjectsInUserGallery = 3

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var galleryButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var findSurfaceView: UIView!
    @IBOutlet weak var findSurfaceLabel: UILabel!
    
    @IBOutlet weak var goCloserToSurfaceView: UIView!
    @IBOutlet weak var goCloserToSurfaceLabel: UILabel!
    @IBOutlet weak var goCloserProgress: UIProgressView!
    
    @IBOutlet weak var placePhoneOnYouHeadView: UIView!
    @IBOutlet weak var placePhoneOnYouHeadLabel: UILabel!
    @IBOutlet weak var placePhoneOnYouHeadCountdown: UILabel!
    @IBOutlet weak var startMeasurementButton: UIButton!
    
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var resultTextLabel: UILabel!
    @IBOutlet weak var resultValueLabel: UILabel!
    @IBOutlet weak var compareButton: UIButton!
    
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
    let minCloserDistanceToSurface = Float(0.15)
    let maxCloserDistanceToSurface = Float(1.6)
    
    let placePhoneCountdownMaxValue = 5
    let placePhoneCountdownTimerInterval = Double(1)
    var placePhoneCountdownTimer = Timer()
    var currentCountdownValue = 0
    
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        galleryButton.isHidden = true
        goCloserToSurfaceView.isHidden = true
        placePhoneOnYouHeadView.isHidden = true
        placePhoneOnYouHeadCountdown.isHidden = true
        resultView.isHidden = true
        
        compareButton.backgroundColor = .clear
        compareButton.titleLabel?.baselineAdjustment = UIBaselineAdjustment.alignCenters
        compareButton.titleLabel?.textAlignment = .center
        compareButton.setTitle(NSLocalizedString("compareButtonTitle", comment: ""), for: UIControlState.normal) 
        
        setupBorder(view: compareButton)
        setupBorder(view: (compareButton.titleLabel)!)
        setupBorder(view: startMeasurementButton)
        
        compareButton.layer.borderWidth = 1
        compareButton.titleLabel?.layer.borderWidth = 0
        
        unit = DistanceUnit.centimeter
        
        let defaults = UserDefaults.standard
        if let measureString = defaults.string(forKey: Setting.measureUnits.rawValue) {
            self.unit = DistanceUnit(rawValue: measureString)!
        } else {
            self.unit = .centimeter
            defaults.set(DistanceUnit.centimeter.rawValue, forKey: Setting.measureUnits.rawValue)
        }
        
        findSurfaceLabel.text = NSLocalizedString("findSurfaceTitle", comment: "")
        goCloserToSurfaceLabel.text = "\(NSLocalizedString("goCloserToSurfaceTitle", comment: "")) \(minCloserDistanceToSurface * unit.fator) \(unit.unit)"
        placePhoneOnYouHeadLabel.text = NSLocalizedString("pressStartTitle", comment: "")
        placePhoneOnYouHeadCountdown.text = "\(placePhoneCountdownMaxValue)"
        currentCountdownValue = placePhoneCountdownMaxValue
        startMeasurementButton.setTitle(NSLocalizedString("startButtonTitle", comment: ""), for: UIControlState.normal)
        resultTextLabel.text = NSLocalizedString("resultTextTitle", comment: "")
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.handleStartARSessionNotification(_:)),
                                               name: Notification.Name(rawValue:AppFeedbackHelper.appFeedbackHelperNotificationKey),
                                               object: nil)
        
        Appodeal.setInterstitialDelegate(self)
    }
    
    fileprivate func setupBorder(view: UIView) {
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 1
        view.layer.borderColor = findSurfaceLabel.textColor.cgColor
    }
    
    fileprivate func setupScene() {
        sceneView.delegate = self
        sceneView.session = session
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
    
    @IBAction func startPressed(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            self?.placePhoneOnYouHeadCountdown.isHidden = false
            self?.startMeasurementButton.isHidden = true
            self?.placePhoneCountdownTimer = Timer.scheduledTimer(timeInterval: (self?.placePhoneCountdownTimerInterval)!, target: self,   selector: (#selector(ViewController.decrementCountdown)), userInfo: nil, repeats: true)
        }
    }
    
    @IBAction func showCelebrityListPressed(_ sender: Any) {
        if RageProducts.store.isProductPurchased(SettingsController.openFullCelebrityListProductId) || RageProducts.store.isProductPurchased(SettingsController.removeAdsPlusLimitProductId) {
            self.rulerScreenNavigationHelper.showCelebrityListFromRuler(compareHeight: heightLength * self.unit.fator)
        } else {
            rulerPurchasesHelper.showBuyFullCelebrityListPopUp(controller: self)
        }
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
    
    @IBAction func redoPressed(_ sender: Any) {
        resultView.isHidden = true
        placePhoneOnYouHeadView.isHidden = false
        placePhoneOnYouHeadCountdown.isHidden = true
        startMeasurementButton.isHidden = false
        currentCountdownValue = placePhoneCountdownMaxValue
        placePhoneOnYouHeadCountdown.text = "\(currentCountdownValue)"
        compareButton.layer.borderWidth = 1
        compareButton.titleLabel?.layer.borderWidth = 0
    }
    
    @IBAction func buyButtonPressed(_ sender: Any) {
        rulerPurchasesHelper.showPurchasesPopUp(controller: self)
    }
    
    @IBAction func sharePressed(_ sender: Any) {
        
        var firstActivityItem = ""
        let size = String(heightLength * self.unit.fator)
        
        var celebrities = ShareResultHelper.getCelebritiesList(measureUnit: unit)
        let userMeasureModel = CelebrityModel(name: NSLocalizedString("resultTextTitle", comment: ""), height: heightLength * self.unit.fator, isUserHeight: true)
        celebrities.append(userMeasureModel)
        celebrities.sort { $0.height > $1.height }
        
        guard let index = celebrities.index(where: {$0.isUserHeight == true}) else { return }
        
        if (index + 1) >= celebrities.count {
            firstActivityItem = NSLocalizedString("myHeightTextTitle", comment: "") + size + " " + self.unit.unit + " #GRuler"
        } else {
            let celebrityGeight = celebrities[index + 1]
            firstActivityItem =  size + " " + self.unit.unit + NSLocalizedString("iAmHigherThanTitle", comment: "") + celebrityGeight.name + "  #GRuler"
        }
        
        let secondActivityItem : NSURL = NSURL(string: RateAppHelper.reviewString)!
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [firstActivityItem, secondActivityItem], applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = self.navigationItem.leftBarButtonItem?.customView
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.unknown
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        self.present(activityViewController, animated: true, completion: nil)
        
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
        userObjectRm.name = "Object" + " " + uuid
        userObjectRm.height = self.getObjectSize() * self.unit.fator
        
        DispatchQueue.main.async {
            try! GRDatabaseManager.sharedDatabaseManager.grRealm.write({
                GRDatabaseManager.sharedDatabaseManager.grRealm.add(userObjectRm, update:true)
                self.galleryButton.isHidden = false
                
                let alert = UIAlertController(title: "", message: NSLocalizedString("savedTitle", comment: ""), preferredStyle: .alert)
                self.present(alert, animated: true, completion: nil)
                
                let when = DispatchTime.now() + 1
                DispatchQueue.main.asyncAfter(deadline: when){
                    // your code with delay
                    alert.dismiss(animated: true, completion: nil)
                }
                
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
        resultValueLabel.text = measureText
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
        
        let userdefaults = UserDefaults()
        var showRemoveAdsProposal = userdefaults.bool(forKey: showRemoveAdsProposalKey)
        
        if showRemoveAdsProposal == false {
            var showAdsCount = userdefaults.integer(forKey: showAdsCountKey)
            showAdsCount = showAdsCount + 1
            userdefaults.set(showAdsCount, forKey: showAdsCountKey)
            if showAdsCount >= 3 {
                showRemoveAdsProposal = true
                userdefaults.set(showRemoveAdsProposal, forKey: showRemoveAdsProposalKey)
                rulerPurchasesHelper.showRemoveAdsProposalAlert(controller: self.presentedViewController)
            }
        }
        
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
        
        if goCloserToSurfaceView.isHidden == true && placePhoneOnYouHeadView.isHidden == true && resultView.isHidden == true {
            DispatchQueue.main.async {
                self.findSurfaceView.isHidden = true
                self.goCloserToSurfaceView.isHidden = false
                self.goCloserToSurfaceTimer = Timer.scheduledTimer(timeInterval: (self.goCloserToSurfaceTimerInterval), target: self,   selector: (#selector(ViewController.checkDistanceToSurface)), userInfo: nil, repeats: true)
            }
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
        let distance = cameraPos.y - plane.worldPosition.y
        
        if distance <= minCloserDistanceToSurface {
            goCloserProgress.progress = 1
            self.goCloserToSurfaceTimer.invalidate()
            goCloserToSurfaceView.isHidden = true
            placePhoneOnYouHeadView.isHidden = false
            
        } else {
            if distance >= maxCloserDistanceToSurface {
                goCloserProgress.progress = 0
            } else {
                let progress = 100 - ((distance - minCloserDistanceToSurface) * 100) / (maxCloserDistanceToSurface - minCloserDistanceToSurface)
                goCloserProgress.progress = progress / 100
            }
        }
    }
    
    @objc func decrementCountdown() {
        currentCountdownValue -= 1
        placePhoneOnYouHeadCountdown.text = "\(currentCountdownValue)"
        
        if currentCountdownValue == 0 {
            self.placePhoneCountdownTimer.invalidate()
            DispatchQueue.main.async { [weak self] in
                self?.measurements = [SCNVector3]()
                self?.startMeasurement = true
                self?.timer = Timer.scheduledTimer(timeInterval: (self?.measureTime)!, target: self,   selector: (#selector(ViewController.finishTimer)), userInfo: nil, repeats: false)
            }
        }
    }
    
    @objc func finishTimer() {
        
        placePhoneOnYouHeadView.isHidden = true
        resultView.isHidden = false
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
            self?.resultValueLabel.text = String(format: "%.2f%@", distance * (self?.unit.fator)!, (self?.unit.unit)!)
            
                if UIDevice.current.userInterfaceIdiom == .phone {
                    AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                } else {
                    
                    guard let url = Bundle.main.url(forResource: "beepSound", withExtension: "wav") else { return }
                    
                    do {
                        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                        try AVAudioSession.sharedInstance().setActive(true)
                        
                        self?.player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
                        
                        self?.player?.play()
                        
                    } catch let error {
                        print(error.localizedDescription)
                    }
            }
            
        }
        
        compareHeightWithCelebrity(height: heightLength * self.unit.fator)
    }
    
    func compareHeightWithCelebrity(height: Float) {
        var celebrities = ShareResultHelper.getCelebritiesList(measureUnit: unit)
        let userMeasureModel = CelebrityModel(name: NSLocalizedString("resultTextTitle", comment: ""), height: height, isUserHeight: true)
        celebrities.append(userMeasureModel)
        celebrities.sort { $0.height > $1.height }
        
        guard let index = celebrities.index(where: {$0.isUserHeight == true}) else { return }
        
        if (index + 1) >= celebrities.count {
            DispatchQueue.main.async { [weak self] in
                self?.compareButton.setTitle(NSLocalizedString("compareButtonTitle", comment: ""), for: UIControlState.normal)
                self?.compareButton.layer.borderWidth = 1
                self?.compareButton.titleLabel?.layer.borderWidth = 0
            }
        } else {
            let celebrityGeight = celebrities[index + 1]
            
            DispatchQueue.main.async { [weak self] in
                self?.compareButton.setTitle(NSLocalizedString("iAmHigherThanTitle", comment: "") + celebrityGeight.name, for: UIControlState.normal)
                
                self?.compareButton.titleLabel?.sizeToFit()
                self?.compareButton.sizeThatFits((self?.compareButton.titleLabel?.intrinsicContentSize)!)
                
                    self?.compareButton.layoutIfNeeded()
                    self?.view.layoutIfNeeded()
                self?.compareButton.layer.borderWidth = 0
                self?.compareButton.titleLabel?.layer.borderWidth = 1
            }
        }
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
            
            let alert = UIAlertController(title: NSLocalizedString("GHeightWouldLikeToAccessTheCamera", comment: ""), message: NSLocalizedString("pleaseGrantPermissionToUseTheCamera", comment: ""), preferredStyle: .alert )
            alert.addAction(UIAlertAction(title: NSLocalizedString("openSettings", comment: ""), style: .cancel) { alert in
                
                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: { (success) in
                })
            })
            present(alert, animated: true, completion: nil)
        }
        
        messageLabel.text = NSLocalizedString("errorOccurred", comment: "")
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
