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

    var businesses: [Business]?
    var searchCriteria: BusinessSearchCriteria?
    var locationManager : CLLocationManager!
    var annotations: [MKAnnotation]?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchMap: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the UISearchBar
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.sizeToFit()
        searchBar.placeholder = "Restaurants"
        searchBar.enablesReturnKeyAutomatically = false
        self.navigationItem.titleView = searchBar
        
        self.searchCriteria = BusinessSearchCriteria()
        self.searchCriteria?.term = ""
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 120
        
        self.searchMap.delegate = self
        
        // setup corelocation
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.distanceFilter = 200
        self.locationManager.requestWhenInUseAuthorization()
        self.searchMap.hidden = true
        
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
    
    @IBAction func onViewChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.tableView.hidden = false
            self.searchMap.hidden = true
        } else {
            self.tableView.hidden = true
            self.searchMap.hidden = false
        }
        self.search()
    }
    
    private func search() {
        let useBounds = !self.searchMap.hidden
        if useBounds {
            if let (ne, sw) = self.getBounds() {
                self.searchCriteria?.setBounds(ne, sw: sw)
            }
        } else {
            self.searchCriteria?.bounds = nil
        }
        if let searchCriteria = self.searchCriteria {
            let categories = Array(searchCriteria.categories!)
            let deals = searchCriteria.deals ?? false
            let sort = searchCriteria.sort
            let radius = searchCriteria.radius
            let bounds = searchCriteria.bounds
            Business.searchWithTerm(
                searchCriteria.term,
                sort: sort,
                categories: categories,
                deals: deals,
                radius: radius,
                bounds: bounds,
                completion: {(businesses: [Business]!, error: NSError!) -> Void in
                    self.businesses = businesses
                    if self.tableView.hidden {
                        self.drawMarkers()
                    } else {
                        self.tableView.reloadData()
                    }
            })
        }
    }

}

extension BusinessesViewController: UITableViewDelegate {
}

extension BusinessesViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("com.lyft.BusinessCell", forIndexPath: indexPath) as! BusinessCell
        
        if let businesses = self.businesses {
            cell.business = businesses[indexPath.row]
        }
        
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
            self.searchCriteria?.location = location
        }
    }
    
    func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        self.searchMap.setRegion(region, animated: false)
    }
    
}

extension BusinessesViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if let (ne, sw) = self.getBounds() {
            self.searchCriteria?.setBounds(ne, sw: sw)
            self.search()
        }
    }
    
    /* commented out to work on it bit more later after due date.  Uncommenting it will make it work with bad looking markers
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "BusinessAnnotationView"
        
        // custom image annotation
        var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? BusinessAnnotationView
        if (annotationView == nil) {
            annotationView = BusinessAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        else {
            annotationView!.annotation = annotation
        }
        
        annotationView?.nameLabel.text = annotation.title ?? "No"
        
        return annotationView
    }
*/
    
    private func getBounds() -> (ne: CLLocationCoordinate2D, sw: CLLocationCoordinate2D)? {
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
    
    private func drawMarkers() {
        if let annotations = self.annotations {
            self.searchMap.removeAnnotations(annotations)
        }
        self.annotations = []
        if let businesses = self.businesses {
            for business in businesses {
                if let location = business.location {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = location.coordinate
                    annotation.title = business.name
                    self.searchMap.addAnnotation(annotation)
                    self.annotations?.append(annotation)
                }
            }
        }
    }
    
}
