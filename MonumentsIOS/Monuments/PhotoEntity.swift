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
    
    var name: String
    var image: UIImage
    var json: NSData

    
    init(name: String, image : UIImage, JSONData : NSData) {
        self.name = name
        self.image = image
        self.json = NSData()

        do {
            self.json = try NSJSONSerialization.JSONObjectWithData(JSONData, options: .AllowFragments) as! NSData
        }
        catch {
            print(error)
        }
    }
}