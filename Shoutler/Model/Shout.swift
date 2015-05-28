//
//  Shout.swift
//  Shoutler
//
//  Created by Diego Haz on 5/24/15.
//  Copyright (c) 2015 Diego Haz. All rights reserved.
//

import UIKit
import CoreLocation
import Parse

class Shout {
    var object: PFObject
    var content: String
    var feeling: Feeling
    var place: Place
    var date: NSDate
    
    init(object: PFObject) {
        self.object = object
        self.content = object["content"] as! String
        self.feeling = Feeling(name: object["feeling"] as! String)
        self.place = Place(object: object["place"] as! PFObject)
        self.date = object.createdAt!
    }
    
    static func shout(content: String, then callback: ((Shout?) -> Void)?) {
        var shout = PFObject(className: "Shout")
        let user = User.current()
        
        shout["content"] = content
        
        user?.save(then: { (user) -> Void in
            shout.saveEventually().continueWithSuccessBlock { (task) -> AnyObject! in
                return shout.fetchIfNeededInBackground()
            }.continueWithBlock { (task) -> AnyObject! in
                dispatch_async(dispatch_get_main_queue()) {
                    var shoutToReturn: Shout?
                    
                    if let result = task.result as? PFObject {
                        shoutToReturn = Shout(object: result)
                    }
                    
                    callback?(shoutToReturn)
                }
                
                return task!
            }
        })
    }
    
    static func list(page: Int, then callback: (([Shout]) -> Void)?) {
        PFCloud.callFunctionInBackground("listShouts", withParameters: ["page": page]) { (results, error) -> Void in
            if error == nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let results = results as! [PFObject]
                    var shouts = [Shout]()
                    
                    for result in results {
                        shouts.append(Shout(object: result))
                    }
                
                    callback?(shouts)
                })
            } else {
//                delay(2, { () -> () in
//                    self.list(page, then: callback)
//                })
            }
        }
    }
}
