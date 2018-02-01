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
    var height = 0
    var isUserHeight = false
}

class CelebrityListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var measureScreen: ViewController!
    var height = Float(0)
    
    fileprivate var celebrities = [CelebrityModel]()
    
    fileprivate var unit: DistanceUnit = .centimeter
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CelebrityViewCell", bundle: nil),  forCellReuseIdentifier:"CelebrityViewCell")
        
        let userMeasureModel = CelebrityModel(name: "You height", height: Int(height), isUserHeight: true)
        celebrities.append(userMeasureModel)
        
        loadCelebritiesList()
        celebrities.sort { $0.height > $1.height }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let index = celebrities.index(where: {$0.name == "You height"}) {
            let scrollPosition = IndexPath(row: index, section: 0)
            tableView.scrollToRow(at: scrollPosition, at: .none, animated: false)
        }
    }
    
    func loadCelebritiesList() {
        
        if let path = Bundle.main.path(forResource: "Celebrities", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let сelebrities = jsonResult["сelebrities"] as? [Any] {
                    
                    for сelebrity in сelebrities {
                        
                        if let сelebrityDict = сelebrity as? [String: Any] {
                            let name = сelebrityDict["name"] as! String
                            let height = Int(сelebrityDict["height"] as! String)
                            let сelebrityModel = CelebrityModel(name: name, height: height!, isUserHeight: false)
                            celebrities.append(сelebrityModel)
                        }
                    }
                }
            } catch {
                
            }
        }
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
