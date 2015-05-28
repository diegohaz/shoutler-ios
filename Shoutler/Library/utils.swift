//
//  utils.swift
//  Shoutler
//
//  Created by Diego Haz on 5/24/15.
//  Copyright (c) 2015 Diego Haz. All rights reserved.
//

import UIKit

func delay(delay: Double, closure: ()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

class LocalizedLabel : UILabel {
    override func awakeFromNib() {
        if let text = text {
            self.text = NSLocalizedString(text, comment: "")
        }
    }
}

class LocalizedButton : UIButton {
    override func awakeFromNib() {
        for state in [UIControlState.Normal, UIControlState.Highlighted, UIControlState.Selected, UIControlState.Disabled] {
            if let title = titleForState(state) {
                setTitle(NSLocalizedString(title, comment: ""), forState: state)
            }
        }
    }
}