//
//  FeelingsController.swift
//  Shoutler
//
//  Created by Diego Haz on 5/24/15.
//  Copyright (c) 2015 Diego Haz. All rights reserved.
//

import UIKit

class FeelingsController: UIViewController {
    
    static let sharedInstance = FeelingsController()
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var blackButton: UIButton!
    @IBOutlet weak var placeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = NSBundle.mainBundle().loadNibNamed("FeelingsView", owner: self, options: [:]).first as! UIView
        
        redButton.tintColor = Feeling(name: "red").color
        greenButton.tintColor = Feeling(name: "green").color
        blueButton.tintColor = Feeling(name: "blue").color
        blackButton.tintColor = Feeling(name: "black").color
        
        for button in [redButton, greenButton, blueButton, blackButton] {
            button.addTarget(self, action: "chooseFeeling:", forControlEvents: .TouchUpInside)
        }
        
        let placeName = User.current()?.place?.name
        
        self.label.text = String(format: NSLocalizedString("Feeling in %@", comment: ""), placeName!)
        self.placeButton.setTitle(String(format: NSLocalizedString("Not in %@", comment: ""), placeName!), forState: .Normal)
    }
    
    func chooseFeeling(sender: UIButton) {
        let user = User.current()
        
        if sender == redButton {
            user?.feeling = Feeling(name: "red")
        } else if sender == greenButton {
            user?.feeling = Feeling(name: "green")
        } else if sender == blueButton {
            user?.feeling = Feeling(name: "blue")
        } else if sender == blackButton {
            user?.feeling = Feeling(name: "black")
        }
        
        MainController.sharedInstance.pushViewController()
    }
    
    @IBAction func choosePlace(sender: AnyObject) {
        MainController.sharedInstance.pushViewController(PlacesController.sharedInstance, pop: true)
    }
}
