//
//  PhotoEntity.swift
//  Monuments
//
//  Created by Gaspard Chevassus on 06/07/2016.
//  Copyright © 2016 Gaspard Chevassus. All rights reserved.
//

import Foundation
import UIKit

class PhotoEntity {
    
    var image: UIImage
    var json: [String: AnyObject]
    var azimuth : String
    var long : String
    var lat : String

    
    init(){
        self.image = UIImage()
        self.json = ["": ""]
        self.lat = ""
        self.long = ""
        self.azimuth = ""
    }
    
    init( image : UIImage, JSONData : NSData, azimuth : String, long : String, lat : String) {
        self.image = image
        self.json = ["": ""]
        self.lat = lat
        self.long = long
        self.azimuth = azimuth
        setJson(lat,long: long,azimuth: azimuth)
        
        if NSJSONSerialization.isValidJSONObject(json) {
            print("dictPoint is valid JSON")
            print(json)
            
        }
        
//        do {
//            self.json = try NSJSONSerialization.JSONObjectWithData(JSONData, options: .AllowFragments) as! NSData
//        }
//        catch {
//            print(error)
//        }
    }
    
    func setJson(lat: String,long : String, azimuth : String) -> () {
        self.json = [
            "jLoc":
                ["lat":lat,
                "long": long],
            "azimuth": azimuth
        ]
    }
}