//
//  UserObjectRm.swift
//  BeaverRuler
//
//  Created by Aleksandr Khotyashov on 8/23/17.
//  Copyright © 2017 Sasha. All rights reserved.
//

import RealmSwift

class UserObjectRm: Object {

    @objc dynamic var id: String?
    @objc dynamic var name: String?
    @objc dynamic var height: Float = 0.00
    @objc dynamic var sizeUnit: String?
    @objc dynamic var createdAt: Date?
    
    override class func primaryKey() -> String{
        return "id"
    }

}
