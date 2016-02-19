//
//  SliderCell.swift
//  Yelp
//
//  Created by Hyun Lim on 2/18/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol SliderCellDelegate {
    optional func sliderCell(sliderCell: SliderCell, didValueChanged value: Int)
}

class SliderCell: UITableViewCell {

    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var distanceLabel: UILabel!
    
    weak var delegate: SliderCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onSliderValueChanged(sender: AnyObject) {
        let value = Int(round(self.slider.value))
        self.setDistanceValue()
        self.delegate?.sliderCell?(self, didValueChanged: value)
    }
    
    internal func setDistanceValue() {
        let miles = self.slider.value / 1609.34
        self.distanceLabel.text = String(format: "%.2f mi", miles)
    }
    
    internal func setValue(value: Float) {
        self.slider.value = value
        setDistanceValue()
    }
    
    
}
