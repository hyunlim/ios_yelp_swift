//
//  SortCell.swift
//  Yelp
//
//  Created by Hyun Lim on 2/18/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol SortCellDelegate {
    optional func sortCell(sortCell: SortCell, didChangeValue value: Int)
}

class SortCell: UITableViewCell {
    
    @IBOutlet weak var sortControl: UISegmentedControl!
    
    weak var delegate: SortCellDelegate?
    
    @IBAction func onSortValueChanged(sender: UISegmentedControl) {
        
        self.delegate?.sortCell?(self, didChangeValue: sender.selectedSegmentIndex)
    }
}
