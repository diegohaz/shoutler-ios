//
//  Place.swift
//  Shoutler
//
//  Created by Diego Haz on 5/24/15.
//  Copyright (c) 2015 Diego Haz. All rights reserved.
//

import UIKit
import CoreLocation
import Parse

class Place {
    var object: PFObject
    var name: String
    var location: CLLocation
    var types = [String]()
    
    init(object: PFObject) {
        self.object = object
        
        self.name = object["name"] as! String
        
        let location = object["location"] as! PFGeoPoint
        self.location = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        let types = object["types"] as! [String]
        self.types += types
    }
    
    func isType(type: String) -> Bool {
        for item in types {
            if item == type {
                return true
            }
        }
        
        return false
    }
    
    static func list(location: CLLocation?, then callback: (([Place]) -> Void)?) {
        let geoPoint = location != nil ? PFGeoPoint(location: location) : NSNull()
        
        PFCloud.callFunctionInBackground("listPlaces", withParameters: ["location": geoPoint]) { (results, error) -> Void in
            if error == nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let results = results as! [PFObject]
                    var places = [Place]()
                    
                    for result in results {
                        places.append(Place(object: result))
                    }
                    
                    callback?(places)
                })
            } else {
                delay(2, { () -> () in
                    self.list(location, then: callback)
                })
            }
        }
    }
}
