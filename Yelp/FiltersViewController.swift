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
        "Categories"
    ]
    
    private var categories:[[String:String]]!
    
    internal var delegate:FiltersViewControllerDelegate?
    private weak var searchCriteria:BusinessSearchCriteria?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // load available selection
        self.categories = BusinessSearchCriteria.yelpCategories()
        
        // load search state into UI
        if let searchCriteria = self.delegate?.loadCriteria(self) {
            self.loadCriteriaIntoUI(searchCriteria)
        }
        
        self.tableView.reloadData()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onCancel(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func onSearch(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let searchCriteria = self.constructCriteriaFromUI()
        
        delegate?.filtersViewController(self, didUpdateFilters: searchCriteria)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
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
        if section == 0 {
            return self.categories.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell
        
        if indexPath.section == 0 {
            let switchCell = tableView.dequeueReusableCellWithIdentifier("com.lyft.SwitchCell", forIndexPath: indexPath) as! SwitchCell
            let category = self.categories[indexPath.row]
            
            switchCell.switchLabel.text = category["name"]
            switchCell.delegate = self
            switchCell.toggleSwitch.on = self.searchCriteria?.categories?.contains(category["code"]!) ?? false
            
            cell = switchCell
        } else {
            cell = UITableViewCell()
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionHeadings[section]
    }
}

extension FiltersViewController: UITableViewDelegate {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
}

extension FiltersViewController: SwitchCellDelegate {
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        if let indexPath = self.tableView.indexPathForCell(switchCell),
            searchCriteria = self.searchCriteria {
            
                if value {
                    searchCriteria.categories?.insert(self.categories[indexPath.row]["code"]!)
                } else {
                    searchCriteria.categories?.remove(self.categories[indexPath.row]["code"]!)
                }
            
        }
    }
}