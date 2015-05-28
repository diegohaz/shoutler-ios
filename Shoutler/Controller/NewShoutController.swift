//
//  NewShoutController.swift
//  Shoutler
//
//  Created by Diego Haz on 5/26/15.
//  Copyright (c) 2015 Diego Haz. All rights reserved.
//

import UIKit

class NewShoutController: UIViewController, UITextViewDelegate {
    
    static let sharedInstance = NewShoutController()
    var newShoutView: NewShoutView?

    @IBOutlet weak var loadingView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = NSBundle.mainBundle().loadNibNamed("NewShoutView", owner: self, options: [:]).last as! NewShoutView
        
        self.newShoutView = self.view as? NewShoutView
        self.newShoutView?.setFeeling(User.current()!.feeling!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "feelingChanged:", name: "feelingChanged", object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        self.newShoutView?.content.becomeFirstResponder()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func touchOutside(sender: AnyObject) {
        ShoutsController.sharedInstance.closeNewShout()
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func shout(sender: AnyObject) {
        self.newShoutView?.content.resignFirstResponder()
        
        let text = self.newShoutView?.content.text
        
        self.loadingView.hidden = false
        
        Shout.shout(text!, then: { (shout) -> Void in
            if shout != nil {
                self.newShoutView?.content.text = ""
                ShoutsController.sharedInstance.shouts.insert(shout!, atIndex: 0)
                ShoutsController.sharedInstance.offscreenCells.removeAll(keepCapacity: true)
                ShoutsController.sharedInstance.collectionView.reloadData()
            }
            
            self.loadingView.hidden = true
            self.touchOutside(UIButton())
        })
    }
    
    @IBAction func changeFeeling(sender: UIButton) {
        let user = User.current()
        
        if sender == self.newShoutView?.redButton {
            user?.feeling = Feeling(name: "red")
        } else if sender == self.newShoutView?.greenButton {
            user?.feeling = Feeling(name: "green")
        } else if sender == self.newShoutView?.blueButton {
            user?.feeling = Feeling(name: "blue")
        } else if sender == self.newShoutView?.blackButton {
            user?.feeling = Feeling(name: "black")
        }
    }
    
    func feelingChanged(notification: NSNotification) {
        let feeling = notification.object as! Feeling
        
        self.newShoutView?.setFeeling(feeling)
    }
    
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if NSString(string: textView.text).length + NSString(string: text).length - range.length >= 255 {
            return false
        }
        
        if !textView.text.isEmpty && contains(text, "\n") {
            self.shout(UIButton())
            return false
        }
        
        return true
    }

}
