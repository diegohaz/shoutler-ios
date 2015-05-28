//
//  NewShoutView.swift
//  Shoutler
//
//  Created by Diego Haz on 5/24/15.
//  Copyright (c) 2015 Diego Haz. All rights reserved.
//

import UIKit

class NewShoutView: UIView {
    @IBOutlet weak var shoutButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    @IBOutlet weak var blackButton: UIButton!
    @IBOutlet weak var content: UITextView!
    
    override func awakeFromNib() {
        self.redButton.imageView?.tintColor = Feeling(name: "red").color
        self.greenButton.imageView?.tintColor = Feeling(name: "green").color
        self.blueButton.imageView?.tintColor = Feeling(name: "blue").color
        self.blackButton.imageView?.tintColor = Feeling(name: "black").color
    }
    
    func setFeeling(feeling: Feeling) {
        let button = self.valueForKey(feeling.name + "Button") as? UIButton
        
        var buttons = [redButton, greenButton, blueButton, blackButton]
        
        for button in buttons {
            button.alpha = 0.25
        }
        
        self.shoutButton.tintColor = feeling.color
        self.cancelButton.imageView?.tintColor = feeling.color
        
        button?.alpha = 1
    }
}
