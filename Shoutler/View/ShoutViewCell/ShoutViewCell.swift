//
//  ShoutViewCell.swift
//  Shoutler
//
//  Created by Diego Haz on 5/24/15.
//  Copyright (c) 2015 Diego Haz. All rights reserved.
//

import UIKit

class ShoutViewCell: UICollectionViewCell {
    @IBOutlet weak var feeling: UIImageView!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var place: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = 5
        self.contentView.backgroundColor = UIColor.whiteColor()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Set what preferredMaxLayoutWidth you want
        content.preferredMaxLayoutWidth = self.bounds.width - 16
    }
}
