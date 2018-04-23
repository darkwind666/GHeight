//
//  ShareResultHelper.swift
//  GHeight
//
//  Created by user on 4/22/18.
//  Copyright © 2018 user. All rights reserved.
//

import Foundation

class ShareResultHelper {
    
    static func getCelebritiesList(measureUnit: DistanceUnit) -> [CelebrityModel] {
        
        var celebritiesList = [CelebrityModel]()
        
        if let path = Bundle.main.path(forResource: "Celebrities", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let сelebrities = jsonResult["сelebrities"] as? [Any] {
                    
                    let conversionFator = measureUnit.fator / (DistanceUnit.centimeter.fator)
                    
                    for сelebrity in сelebrities {
                        
                        if let сelebrityDict = сelebrity as? [String: Any] {
                            let name = сelebrityDict["name"] as! String
                            let height = Int(сelebrityDict["height"] as! String)
                            let сelebrityModel = CelebrityModel(name: name, height: Float(height!) * conversionFator, isUserHeight: false)
                            celebritiesList.append(сelebrityModel)
                        }
                    }
                }
            } catch {
                
            }
        }
        
        return celebritiesList
        
    }
    
}
