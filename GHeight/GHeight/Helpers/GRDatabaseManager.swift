//
//  VTDatabaseManager.swift
//  Velotooler
//
//  Created by Sasha Khotiashov on 5/30/16.
//  Copyright © 2016 Velotooler. All rights reserved.
//

import RealmSwift

class GRDatabaseManager {

    static let sharedDatabaseManager  = GRDatabaseManager()
    var grRealm: Realm!

    init() {
        Realm.Configuration.defaultConfiguration.deleteRealmIfMigrationNeeded = true
        grRealm = try! Realm()
    }

}
