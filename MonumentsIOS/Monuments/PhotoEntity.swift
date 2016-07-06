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
    var json: NSData
    var azimuth : String
    var long : String
    var lat : String

    
    init(){
        self.image = UIImage()
        self.json = NSData()
        self.lat = ""
        self.long = ""
        self.azimuth = ""
    }
    
    init( image : UIImage, JSONData : NSData, azimuth : String, long : String, lat : String) {
        self.image = image
        self.json = NSData()
        self.lat = lat
        self.long = long
        self.azimuth = azimuth

        do {
            self.json = try NSJSONSerialization.JSONObjectWithData(JSONData, options: .AllowFragments) as! NSData
        }
        catch {
            print(error)
        }
    }
}