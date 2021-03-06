//
//  CelebrityListViewController.swift
//  GHeight
//
//  Created by user on 1/22/18.
//  Copyright © 2018 user. All rights reserved.
//

import UIKit

struct CelebrityModel {
    var name = ""
    var height = Float(0)
    var isUserHeight = false
}

class CelebrityListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var measureScreen: ViewController!
    var height = Float(0)
    
    fileprivate var celebrities = [CelebrityModel]()
    
    var unit: DistanceUnit = .centimeter
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(CelebrityListViewController.shareResult))
        self.navigationItem.leftBarButtonItem = leftButtonItem
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CelebrityViewCell", bundle: nil),  forCellReuseIdentifier:"CelebrityViewCell")
        
        loadCelebritiesList()
        
        let userMeasureModel = CelebrityModel(name: NSLocalizedString("resultTextTitle", comment: ""), height: height, isUserHeight: true)
        celebrities.append(userMeasureModel)
        celebrities.sort { $0.height > $1.height }
        
        AppAnalyticsHelper.sendAppAnalyticEvent(withName: "celebrity_list_screen")
    }
    
    @objc func shareResult() {
        
        AppAnalyticsHelper.sendAppAnalyticEvent(withName: "share_result_celebruty_list_pressed")
        
        var firstActivityItem = ""
        let size = String(height)
        
        guard let index = celebrities.index(where: {$0.isUserHeight == true}) else {return}
        if (index + 1) >= celebrities.count {
            firstActivityItem = NSLocalizedString("myHeightTextTitle", comment: "") + size + " " + unit.unit + " #GHeight"
        } else {
            let celebrityGeight = celebrities[index + 1]
            firstActivityItem =  size + " " + unit.unit + NSLocalizedString("iAmHigherThanTitle", comment: "") + celebrityGeight.name + "  #GHeight"
        }
        
        let secondActivityItem : NSURL = NSURL(string: RateAppHelper.reviewString)!
        
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [firstActivityItem, secondActivityItem], applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = self.navigationItem.leftBarButtonItem?.customView
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.unknown
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let index = celebrities.index(where: {$0.name == NSLocalizedString("resultTextTitle", comment: "")}) {
            let scrollPosition = IndexPath(row: index, section: 0)
            tableView.scrollToRow(at: scrollPosition, at: .none, animated: false)
        }
    }
    
    func loadCelebritiesList() {
        celebrities = ShareResultHelper.getCelebritiesList(measureUnit: unit)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return celebrities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        cell = showUserObject(indexPath: indexPath)
        return cell
    }
    
    func showUserObject(indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: "CelebrityViewCell", for: indexPath) as? CelebrityViewCell)!
        let celebrityData = celebrities[indexPath.row]
        
        cell.celebrityName.text = celebrityData.name
        cell.celebrityHeight.text = String(format: "%.2f%", Float(celebrityData.height)) + " " + unit.unit
        
        if celebrityData.isUserHeight {
             cell.celebrityName.textColor = UIColor.red
             cell.celebrityHeight.textColor = UIColor.red
        } else {
            cell.celebrityName.textColor = UIColor.black
            cell.celebrityHeight.textColor = UIColor.black
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // MARK: - EditObjectVCDelegate
    func reloadObjects() {
        tableView.reloadData()
    }
    
}
