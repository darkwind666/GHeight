//
//  ObjectsFoldersViewController.swift
//  BeaverRuler
//
//  Created by Aleksandr Khotyashov on 8/23/17.
//  Copyright © 2017 Sasha. All rights reserved.
//

import UIKit

class ObjectsFoldersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var userObjects = GRDatabaseManager.sharedDatabaseManager.grRealm.objects(UserObjectRm.self).sorted(byKeyPath: "createdAt", ascending: false)

    fileprivate var unit: DistanceUnit = .centimeter

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "UserObjectViewCell", bundle: nil),  forCellReuseIdentifier:"UserObjectViewCell")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userObjects.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        cell = showUserObject(indexPath: indexPath)
        return cell
    }
    
    func showUserObject(indexPath: IndexPath) -> UITableViewCell {
        let cell = (tableView.dequeueReusableCell(withIdentifier: "UserObjectViewCell", for: indexPath) as? UserObjectViewCell)!
        
        
        let userObjectData = userObjects[cell.objectIndex]
        
        if let name = userObjectData.name {
            cell.objectName.text = name
        }
        
        let objectUnit = DistanceUnit(rawValue: userObjectData.sizeUnit!)
        let conversionFator = unit.fator / (objectUnit?.fator)!
        cell.objectSize.text = String(format: "%.2f%", userObjectData.height * conversionFator) + " " + unit.unit
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 220
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // MARK: - EditObjectVCDelegate
    func reloadObjects() {
        tableView.reloadData()
    }

}
