//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class BusinessesViewController: UIViewController {

    var businesses: [Business]!
    var searchCriteria: BusinessSearchCriteria?
    var locationManager : CLLocationManager!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchMap: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the UISearchBar
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.placeholder = "Restaurants"
        self.navigationItem.titleView = searchBar
        
        self.searchCriteria = BusinessSearchCriteria()
        self.searchCriteria?.term = ""
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 120
        
        // setup corelocation
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.distanceFilter = 200
        self.locationManager.requestWhenInUseAuthorization()
        
        self.search()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let navigationController = segue.destinationViewController as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        filtersViewController.delegate = self
    }
    
    private func search() {
        if let searchCriteria = self.searchCriteria {
            let categories = Array(searchCriteria.categories!)
            let deals = searchCriteria.deals ?? false
            let sort = searchCriteria.sort
            let radius = searchCriteria.radius
            Business.searchWithTerm(
                searchCriteria.term,
                sort: sort,
                categories: categories,
                deals: deals,
                radius: radius,
                completion: {(businesses: [Business]!, error: NSError!) -> Void in
                    self.businesses = businesses
                    self.tableView.reloadData()
            })
        }
    }

}

extension BusinessesViewController: UITableViewDelegate {
}

extension BusinessesViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("com.lyft.BusinessCell", forIndexPath: indexPath) as! BusinessCell
        
        cell.business = self.businesses[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let businesses = self.businesses {
            return businesses.count
        } else {
            return 0
        }
    }
}

extension BusinessesViewController: FiltersViewControllerDelegate {
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters searchCriteria: BusinessSearchCriteria) {
        self.search()
    }
    
    func loadCriteria(filtersViewController: FiltersViewController) -> BusinessSearchCriteria? {
        return self.searchCriteria
    }
}

extension BusinessesViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchCriteria = BusinessSearchCriteria()
        self.searchCriteria?.term = searchBar.text ?? ""
        self.search()
    }
    
}

extension BusinessesViewController: CLLocationManagerDelegate {
 
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.goToLocation(location)
        }
    }
    
    func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        self.searchMap.setRegion(region, animated: true)
    }
    
    func getBounds() -> (neCoord: CLLocationCoordinate2D, swCoord: CLLocationCoordinate2D)? {
        if let mapView = self.searchMap {
            let mRect = mapView.visibleMapRect
            let neMapPoint = MKMapPointMake(MKMapRectGetMaxX(mRect), mRect.origin.y)
            let neCoord = MKCoordinateForMapPoint(neMapPoint)
            let swMapPoint = MKMapPointMake(mRect.origin.x, MKMapRectGetMaxY(mRect))
            let swCoord = MKCoordinateForMapPoint(swMapPoint)
            return (neCoord, swCoord)
        }
        
        return nil
    }
    
}
