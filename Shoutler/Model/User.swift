//
//  User.swift
//  Shoutler
//
//  Created by Diego Haz on 5/24/15.
//  Copyright (c) 2015 Diego Haz. All rights reserved.
//

import UIKit
import CoreLocation
import Parse

class User {
    
    private static let currentUser = User()
    
    private var _feeling: Feeling?
    private var _location: CLLocation?
    private var _place: Place?
    
    var object: PFUser?
    
    var feeling: Feeling? {
        set {
            self.object?["feeling"] = newValue?.name ?? NSNull()
            self._feeling = newValue
            
            if self === User.currentUser  {
                NSNotificationCenter.defaultCenter().postNotificationName("feelingChanged", object: newValue)
            }
        }
        get {
            return self._feeling
        }
    }
    
    var location: CLLocation? {
        set {
            self.object?["location"] = PFGeoPoint(location: newValue)
            self._location = newValue
        }
        get {
            return self._location
        }
    }
    
    var locationAccuracy: Double? {
        set {
            self.object?["locationAccuracy"] = newValue ?? NSNull()
        }
        get {
            return self.object?["locationAccuracy"] as? Double
        }
    }
    
    var ignoreLocation: Bool {
        set {
            self.object?["ignoreLocation"] = newValue ?? false
        }
        get {
            return self.object?["ignoreLocation"] as? Bool ?? false
        }
    }
    
    var place: Place? {
        set {
            self.object?["place"] = newValue?.object ?? NSNull()
            self._place = newValue
            
            if self === User.currentUser {
                NSNotificationCenter.defaultCenter().postNotificationName("placeChanged", object: self._place)
            }
        }
        get {
            return self._place
        }
    }
    
    static func translate(object: PFUser) -> User {
        let user = User()
        
        return user.translate(object)
    }
    
    func translate(object: PFUser) -> User {
        self.object = object
        self.locationAccuracy = object["locationAccuracy"] as? Double
        self.ignoreLocation = object["ignoreLocation"] as? Bool ?? false
        
        if let feeling = object["feeling"] as? String {
            self.feeling = Feeling(name: feeling)
        }
        
        if let location = object["location"] as? PFGeoPoint {
            self.location = CLLocation(latitude: location.latitude, longitude: location.longitude)
        }
        
        if let place = object["place"] as? PFObject {
            if !place.isDataAvailable() {
                place.fetchFromLocalDatastore()
            }
            
            if place.isDataAvailable() {
                self.place = Place(object: place)
            } else if place.fetchIfNeeded() != nil {
                place.pinInBackgroundWithName("place")
                self.place = Place(object: place)
            }
        }
        
        return self
    }
    
    func save(then callback: ((User) -> Void)?) {
        self.object?.saveInBackground().continueWithBlock { (task) -> AnyObject! in
            if task.error == nil {
                return self.object!.fetchInBackground()
            }
            
            return task
        }.continueWithBlock { (task) -> AnyObject! in
            if task.error == nil {
                if let place = self.object!["place"] as? PFObject {
                    return place.fetchIfNeededInBackground()
                }
            }
            
            return task
        }.continueWithBlock { (task) -> AnyObject! in
            if task.error == nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let place = task.result as! PFObject
                    place.pinInBackgroundWithName("place")
                    callback?(self.translate(self.object!))
                })
            } else {
                delay(2, { () -> () in
                    self.save(then: callback)
                })
            }
            
            return task
        }
    }

    static func current() -> User? {
        if self.currentUser.object == nil {
            if let user = PFUser.currentUser() {
                self.currentUser.translate(user)
            }
        }
        
        if self.currentUser.object != nil {
            return self.currentUser
        } else {
            return nil
        }
    }
    
    static func login(then callback: ((User) -> Void)?) {
        if let user = self.current() {
            callback?(user)
        } else {
            PFAnonymousUtils.logInWithBlock({ (user, error) -> Void in
                if error == nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        callback?(self.translate(user!))
                    })
                } else {
                    if error!.code == 101 {
                        self.logout()
                    }
                    
                    delay(2, { () -> () in
                        self.login(then: callback)
                    })
                }
            })
        }
    }
    
    static func logout() {
        PFUser.logOut()
    }
}
