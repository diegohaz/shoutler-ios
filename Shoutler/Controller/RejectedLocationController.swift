//
//  RejectedLocationController.swift
//  Shoutler
//
//  Created by Diego Haz on 5/24/15.
//  Copyright (c) 2015 Diego Haz. All rights reserved.
//

import UIKit

class RejectedLocationController: UIViewController {
    
    static let sharedInstance = RejectedLocationController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = NSBundle.mainBundle().loadNibNamed("RejectedLocationView", owner: self, options: [:]).first as! UIView
    }

    @IBAction func openSettings(sender: AnyObject) {
        if let url = NSURL(string:UIApplicationOpenSettingsURLString) {
            self.dismissViewControllerAnimated(true, completion: nil)
            UIApplication.sharedApplication().openURL(url)
        }
    }
}
