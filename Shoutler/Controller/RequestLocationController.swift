//
//  RequestLocationController.swift
//  Shoutler
//
//  Created by Diego Haz on 5/24/15.
//  Copyright (c) 2015 Diego Haz. All rights reserved.
//

import UIKit

class RequestLocationController: UIViewController {
    
    static let sharedInstance = RequestLocationController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = NSBundle.mainBundle().loadNibNamed("RequestLocationView", owner: self, options: [:]).first as! UIView
    }

    @IBAction func request(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let main = MainController.sharedInstance
        
        main.locationManager.requestWhenInUseAuthorization()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
