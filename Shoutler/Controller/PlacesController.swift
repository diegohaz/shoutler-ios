//
//  PlacesController.swift
//  Shoutler
//
//  Created by Diego Haz on 5/24/15.
//  Copyright (c) 2015 Diego Haz. All rights reserved.
//

import UIKit

class PlacesController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    static let sharedInstance = PlacesController()
    @IBOutlet weak var tableView: UITableView!
    var places = [Place]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = NSBundle.mainBundle().loadNibNamed("PlacesView", owner: self, options: [:]).first as! UIView
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewDidAppear(animated: Bool) {
        Place.list(MainController.sharedInstance.location) { (places) -> Void in
            self.places = places
            self.tableView.reloadData()
        }
    }

    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        MainController.sharedInstance.pushViewController()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? UITableViewCell
        
        cell?.textLabel?.text = places[indexPath.row].name
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let user = User.current()
        
        user?.ignoreLocation = true
        user?.place = places[indexPath.row]
        user?.save(then: { (user) -> Void in
            MainController.sharedInstance.pushViewController()
        })
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
