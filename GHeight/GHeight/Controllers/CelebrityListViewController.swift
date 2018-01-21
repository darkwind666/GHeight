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
}

class CelebrityListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var celebrities = [CelebrityModel]()
    
    fileprivate var unit: DistanceUnit = .centimeter
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "CelebrityViewCell", bundle: nil),  forCellReuseIdentifier:"CelebrityViewCell")
        
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
        cell.celebrityHeight.text = String(format: "%.2f%", Float(celebrityData.height) * unit.fator) + " " + unit.unit
        
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
