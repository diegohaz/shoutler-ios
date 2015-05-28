//
//  Feeling.swift
//  Shoutler
//
//  Created by Diego Haz on 5/24/15.
//  Copyright (c) 2015 Diego Haz. All rights reserved.
//

import UIKit

class Feeling {
    var name: String
    var color: UIColor
    var image: UIImage?
    
    init(name: String) {
        self.name = name
        
        switch name {
        case "red":
            self.color = UIColor(red: 232/255, green: 65/255, blue: 103/255, alpha: 1)
            self.image = UIImage(named: "Red")
            break
        case "green":
            self.color = UIColor(red: 113/255, green: 165/255, blue: 63/255, alpha: 1)
            self.image = UIImage(named: "Green")
            break
        case "blue":
            self.color = UIColor(red: 33/255, green: 141/255, blue: 181/255, alpha: 1)
            self.image = UIImage(named: "Blue")
            break
        case "black":
            self.color = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1)
            self.image = UIImage(named: "Black")
            break
        default:
            self.color = UIColor(red: 232/255, green: 65/255, blue: 103/255, alpha: 1)
            self.image = UIImage(named: "Red")
            break
        }
        
        self.image = self.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    }
}
