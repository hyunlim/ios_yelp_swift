//
//  BusinessCell.swift
//  Yelp
//
//  Created by Hyun Lim on 2/18/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessCell: UITableViewCell {

    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var reviewsCountLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var business:Business? {
        didSet {
            if let business = self.business {
                self.nameLabel.text = business.name
                self.thumbImageView.setImageWithURL(business.imageURL!)
                self.ratingImageView.setImageWithURL(business.ratingImageURL!)
                if let reviewCount = business.reviewCount {
                    self.reviewsCountLabel.text = "\(reviewCount) Reviews"
                }
                self.addressLabel.text = business.address
                self.categoriesLabel.text = business.categories
                self.distanceLabel.text = business.distance
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.thumbImageView.layer.cornerRadius = 5
        self.thumbImageView.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
