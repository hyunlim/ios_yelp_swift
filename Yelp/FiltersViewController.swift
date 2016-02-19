//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Hyun Lim on 2/18/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

protocol FiltersViewControllerDelegate {
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters criteria:BusinessSearchCriteria)
    func loadCriteria(filtersViewController: FiltersViewController) -> BusinessSearchCriteria?
}

class FiltersViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let sectionHeadings = [
        "Deals",
        "Sort By",
        "Categories"
    ]
    
    private var categories:[[String:String]]!
    
    internal var delegate:FiltersViewControllerDelegate?
    private weak var searchCriteria:BusinessSearchCriteria?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 120
        
        // load available selection
        self.categories = BusinessSearchCriteria.yelpCategories()
        
        // load search criteria into UI
        if let searchCriteria = self.delegate?.loadCriteria(self) {
            self.loadCriteriaIntoUI(searchCriteria)
        }
        
        self.tableView.reloadData()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onSearch(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let searchCriteria = self.constructCriteriaFromUI()
        
        delegate?.filtersViewController(self, didUpdateFilters: searchCriteria)
    }
    
    private func constructCriteriaFromUI() -> BusinessSearchCriteria {
        let searchCriteria = self.searchCriteria ?? BusinessSearchCriteria()
    
        return searchCriteria
    }
    
    private func loadCriteriaIntoUI(searchCriteria: BusinessSearchCriteria) -> Void {
        self.searchCriteria = searchCriteria
    }

}

extension FiltersViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        switch(section) {
        case 0:
            count = 1
            break
        case 1:
            count = 1
            break
        case 2:
            count = self.categories.count
            break
        default:
            count = 0
            break
        }
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        
        switch indexPath.section {
        case 0:
            let switchCell = tableView.dequeueReusableCellWithIdentifier("com.lyft.SwitchCell", forIndexPath: indexPath) as! SwitchCell
            
            switchCell.switchLabel.text = "Deals Only"
            switchCell.delegate = self
            switchCell.toggleSwitch.on = self.searchCriteria?.deals ?? false
            
            cell = switchCell
            break
        case 1:
            let sortCell = tableView.dequeueReusableCellWithIdentifier("com.lyft.SortCell", forIndexPath: indexPath) as! SortCell
            
            sortCell.delegate = self
            sortCell.sortControl.selectedSegmentIndex = self.searchCriteria?.sort?.rawValue ?? 0
            
            cell = sortCell
            break
        case 2:
            let switchCell = tableView.dequeueReusableCellWithIdentifier("com.lyft.SwitchCell", forIndexPath: indexPath) as! SwitchCell
            let category = self.categories[indexPath.row]
            
            switchCell.switchLabel.text = category["name"]
            switchCell.delegate = self
            switchCell.toggleSwitch.on = self.searchCriteria?.categories?.contains(category["code"]!) ?? false
            
            cell = switchCell
            break
        default:
            cell = UITableViewCell()
            break
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionHeadings[section]
    }
}

extension FiltersViewController: UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sectionHeadings.count
    }
}

extension FiltersViewController: SwitchCellDelegate {
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        if let indexPath = self.tableView.indexPathForCell(switchCell),
            searchCriteria = self.searchCriteria {
            
                switch(indexPath.section) {
                case 0:
                    searchCriteria.deals = value
                case 2:
                    if let categoryCode = self.categories[indexPath.row]["code"] {
                        if value {
                            searchCriteria.categories?.insert(categoryCode)
                        } else {
                            searchCriteria.categories?.remove(categoryCode)
                        }
                    }
                    break
                default:
                    break
                }
        }
    }
}

extension FiltersViewController: SortCellDelegate {
    
    func sortCell(sortCell: SortCell, didChangeValue value: Int) {
        self.searchCriteria?.sort = YelpSortMode(rawValue: value)
    }
    
}