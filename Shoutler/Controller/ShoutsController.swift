//
//  ShoutsController.swift
//  Shoutler
//
//  Created by Diego Haz on 5/25/15.
//  Copyright (c) 2015 Diego Haz. All rights reserved.
//

import UIKit

class ShoutsController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UITextViewDelegate {
    
    static let sharedInstance = ShoutsController()
    
    var offscreenCells = Dictionary<String, UICollectionViewCell>()
    
    @IBOutlet weak var placeLoading: UIActivityIndicatorView!
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var newShoutLabel: UILabel!
    @IBOutlet weak var feeling: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var newShoutBar: UIControl!
    @IBOutlet weak var newShoutBarHeight: NSLayoutConstraint!
    var refreshControl: UIRefreshControl?
    
    var shouts = [Shout]()
    var loading = false
    var lastPage = false
    var page = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = NSBundle.mainBundle().loadNibNamed("ShoutsView", owner: self, options: [:]).first as! UIView
        
        let user = User.current()
        
        self.setFeeling(user!.feeling!)
        self.setPlace(user!.place!)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "feelingChanged:", name: "feelingChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "placeChanged:", name: "placeChanged", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "placeChanging:", name: "placeChanging", object: nil)
        
        self.collectionView.registerNib(UINib(nibName: "ShoutViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.tintColor = UIColor.whiteColor()
        self.refreshControl!.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.collectionView.addSubview(self.refreshControl!)
        
        Shout.list(0, then: { (shouts) -> Void in
            self.shouts = shouts
            self.collectionView.reloadData()
        })
    }
    
    func refresh(sender: UIRefreshControl) {
        Shout.list(0, then: { (shouts) -> Void in
            self.page = 0
            self.lastPage = false
            self.shouts = shouts
            self.offscreenCells = Dictionary<String, UICollectionViewCell>()
            self.collectionView.reloadData()
            self.refreshControl?.endRefreshing()
        })
    }
    
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if self.shouts.count < 15 || self.lastPage || self.loading {
            return
        }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.size.height {
            self.loading = true
            
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
            activityIndicator.frame = CGRectMake(0, contentHeight - 64, 64, 64);
            activityIndicator.center.x = scrollView.center.x
            activityIndicator.startAnimating()
            scrollView.addSubview(activityIndicator)
            
            Shout.list(++self.page, then: { (shouts) -> Void in
                if shouts.count == 0 {
                    self.lastPage = true
                } else {
                    self.shouts += shouts
                    self.offscreenCells = Dictionary<String, UICollectionViewCell>()
                    self.collectionView.reloadData()
                }
                activityIndicator.removeFromSuperview()
                self.loading = false
            })
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func choosePlace(sender: AnyObject) {
        MainController.sharedInstance.pushViewController(PlacesController.sharedInstance, pop: true)
    }
    
    @IBAction func openNewShout(sender: UIControl) {
        self.newShoutBarHeight.constant = 240
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.newShoutBar.backgroundColor = UIColor.whiteColor()
            self.feeling.alpha = 0
            self.view.layoutIfNeeded()
        }) { (finished) -> Void in
            let controller = NewShoutController.sharedInstance
            controller.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            controller.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
            
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func closeNewShout() {
        self.newShoutBarHeight.constant = 48
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.newShoutBar.backgroundColor = UIColor(white: 0, alpha: 0.25)
            self.feeling.alpha = 1
            self.view.layoutIfNeeded()
        })
    }
    
    func feelingChanged(notification: NSNotification) {
        let feeling = notification.object as! Feeling
        
        self.setFeeling(feeling)
    }
    
    func placeChanged(notification: NSNotification) {
        let place = notification.object as! Place
        
        if placeName.text == place.name {
            self.placeLoading.stopAnimating()
            return
        }
        
        self.setPlace(place)
        self.placeLoading.stopAnimating()
        
        self.refresh(self.refreshControl!)
    }
    
    func placeChanging(notification: NSNotification) {
        self.placeLoading.startAnimating()
    }
    
    func setFeeling(feeling: Feeling) {
        self.view.backgroundColor = feeling.color
        self.feeling.image = feeling.image
        self.feeling.tintColor = feeling.color
    }
    
    func setPlace(place: Place) {
        self.placeName.text = place.name
        self.newShoutLabel.text = String(format: NSLocalizedString("Shout in %@", comment: ""), place.name)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.shouts.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        // Set up desired width
        let targetWidth: CGFloat = self.collectionView.bounds.width - 16
        
        // Use fake cell to calculate height
        var cell: ShoutViewCell? = self.offscreenCells["shout" + indexPath.row.description] as? ShoutViewCell
        if cell == nil {
            cell = NSBundle.mainBundle().loadNibNamed("ShoutViewCell", owner: self, options: nil)[0] as? ShoutViewCell
            
            cell?.content.text = self.shouts[indexPath.row].content
            
            self.offscreenCells["shout" + indexPath.row.description] = cell
        }
        
        // Config cell and let system determine size
        
        
        // Cell's size is determined in nib file, need to set it's width (in this case), and inside, use this cell's width to set label's preferredMaxLayoutWidth, thus, height can be determined, this size will be returned for real cell initialization
        cell!.bounds = CGRectMake(0, 0, targetWidth, cell!.bounds.height)
        cell!.contentView.bounds = cell!.bounds
        
        // Layout subviews, this will let labels on this cell to set preferredMaxLayoutWidth
        cell!.setNeedsLayout()
        cell!.layoutIfNeeded()
        
        var size = cell!.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        // Still need to force the width, since width can be smalled due to break mode of labels
        size.width = targetWidth
        
        return size
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ShoutViewCell
        
        // Configure the cell
        let shout = self.shouts[indexPath.row]
        cell.feeling.image = shout.feeling.image
        cell.feeling.tintColor = shout.feeling.color
        cell.content.text = shout.content
        cell.date.text = NSDate(timeIntervalSinceNow: shout.date.timeIntervalSinceNow).timeAgo
        cell.place.text = shout.place.name
        
        return cell
    }
    
}
