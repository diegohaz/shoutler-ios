//
//  MainController.swift
//  Shoutler
//
//  Created by Diego Haz on 5/24/15.
//  Copyright (c) 2015 Diego Haz. All rights reserved.
//

import UIKit
import CoreLocation

class MainController: UIViewController, CLLocationManagerDelegate {
    
    static let sharedInstance = MainController()
    let locationManager = CLLocationManager()
    var location: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 10

        self.view = NSBundle.mainBundle().loadNibNamed("LoadingView", owner: self, options: [:]).first as! UIView
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "feelingChanged:", name: "feelingChanged", object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        User.login { (user) -> Void in
            self.view.backgroundColor = user.feeling?.color ?? Feeling(name: "").color
            user.ignoreLocation = false
            
            if self.location != nil {
                self.locationManager(self.locationManager, didUpdateLocations: [self.location!])
            } else if user.location != nil {
                self.location = user.location
            }
            
            self.pushViewController()
        }
    }
    
    func feelingChanged(notification: NSNotification) {
        let feeling = notification.object as! Feeling
        self.view.backgroundColor = feeling.color
    }
    
    func pushViewController() {
        let user = User.current()
        
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            self.pushViewController(RequestLocationController.sharedInstance, pop: true)
        } else if CLLocationManager.authorizationStatus() == .Denied {
            self.pushViewController(RejectedLocationController.sharedInstance, pop: true)
        } else if user?.feeling == nil {
            self.pushViewController(FeelingsController.sharedInstance, pop: true)
        } else if user?.place != nil {
            self.pushViewController(ShoutsController.sharedInstance, pop: true)
        }
    }
    
    func pushViewController(controller: UIViewController, pop: Bool) {
        if self.presentedViewController == controller {
            return
        }
        
        if pop {
            self.presentedViewController?.dismissViewControllerAnimated(true, completion: nil)
        }
        
        controller.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        controller.modalTransitionStyle = UIModalTransitionStyle.CoverVertical
        
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            self.locationManager.startUpdatingLocation()
        } else if status == .Denied {
            self.pushViewController(RejectedLocationController.sharedInstance, pop: true)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as? CLLocation
        self.location = location
        println(location)
        
        let user = User.current()
        
        if user?.ignoreLocation == false || user?.location?.distanceFromLocation(location!) > 250 {
            NSNotificationCenter.defaultCenter().postNotificationName("placeChanging", object: nil)
            user?.ignoreLocation = false
            user?.location = location
            user?.locationAccuracy = location?.horizontalAccuracy
            user?.save(then: { (user) -> Void in
                if self.presentedViewController == nil {
                    self.pushViewController()
                }
            })
        }
    }

}
