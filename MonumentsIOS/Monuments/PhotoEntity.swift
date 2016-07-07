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
    var jsonString: String
    var azimuth : String
    var long : String
    var lat : String

    
    init(){
        self.image = UIImage()
        self.jsonString = ""
        self.lat = ""
        self.long = ""
        self.azimuth = ""
    }
    
    init( image : UIImage, JSONData : NSData, azimuth : String, long : String, lat : String) {
        self.image = image
        self.jsonString = ""
        self.lat = lat
        self.long = long
        self.azimuth = azimuth
        setJson(lat,long: long,azimuth: azimuth)
        
//        if NSJSONSerialization.isValidJSONObject(json) {
//            print("dictPoint is valid JSON")
//            print(json)
//            
//        }
        
//        do {
//            self.json = try NSJSONSerialization.JSONObjectWithData(JSONData, options: .AllowFragments) as! NSData
//        }
//        catch {
//            print(error)
//        }
    }
    
    func setJson(lat: String,long : String, azimuth : String) -> () {
        
        
        let jLoc:NSMutableDictionary = NSMutableDictionary()
        jLoc.setValue(self.lat, forKey: "lat")
        jLoc.setValue(self.long, forKey: "long")
        
        
        let para:NSMutableDictionary = NSMutableDictionary()
        para.setValue(jLoc, forKey: "jLoc")
        para.setValue(self.azimuth, forKey: "azimuth")
        
        
        // let jsonError: NSError?
        let jsonData: NSData
        do{
            jsonData = try NSJSONSerialization.dataWithJSONObject(para, options: NSJSONWritingOptions())
            let jsonString = NSString(data: jsonData, encoding: NSUTF8StringEncoding) as! String
            print("json string = \(jsonString)")
            self.jsonString = jsonString
        } catch _ {
            print ("UH OOO")
        }
        
        
//        let jLoc: [String: AnyObject] =
//            ["lat":lat,
//             "long": long]
//            
//            
//        self.json = [
//            "jLoc": jLoc,
//            "azimuth": azimuth
//        ]
    
    }
}