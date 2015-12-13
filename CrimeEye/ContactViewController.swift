//
//  ContactViewController.swift
//  CrimeEye
//
//  Created by Gurpreet Paul on 12/12/2015.
//  Copyright © 2015 Crime Eye. All rights reserved.
//

import UIKit
import Siesta
import MapKit

class ContactViewController:
    UIViewController,
    UITableViewDataSource,
    UITableViewDelegate,
    ResourceObserver {

    @IBOutlet weak var phoneLabel:      UILabel!
    @IBOutlet weak var websiteLabel:    UILabel!
    @IBOutlet weak var emailLabel:      UILabel!
    @IBOutlet weak var tableView:       UITableView!
    @IBOutlet weak var mapView:         MKMapView!

    
    var links = [Link]()
    
    /// Contact details of the neighbourhood team
    var contactDetails: Resource? {
        didSet {
            oldValue?.removeObservers(ownedBy: self)
            contactDetails?.addObserver(self).loadIfNeeded()
        }
    }
    
    /// Stores the user's neighbourhood
    var neighbourhood: Resource? {
        didSet {
            oldValue?.removeObservers(ownedBy: self)
            neighbourhood?.addObserver(self).loadIfNeeded()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Style.viewBackground
        
        self.definesPresentationContext = true
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = Style.viewBackground
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        // Auto set the tableview's cells height
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 60.0
        
        // Need a handle on the coords
        let lat = Store.defaults.doubleForKey(Store.LAT)
        let lng = Store.defaults.doubleForKey(Store.LONG)
        
        // Make our first API call to find the user's
        // neighbourhood now.
        neighbourhood = PoliceAPI.locateNeighbourhood(lat, lng: lng)
    }
    
    
    /**
     If the neighbourhood resource is populated, then we can
     make the call to the API
     */
    internal func getCDetailsFromAPI() {
        if let force = neighbourhood?.json["force"].stringValue,
            nCode = neighbourhood?.json["neighbourhood"].stringValue {
                contactDetails =
                    PoliceAPI.getContactDetails(force, neighbourhoodCode: nCode)
        }
    }
    
    
    /**
     Locates where an address is and adds a marker to the map
     - parameters:
        - addr: Address to find
        - type: E.g station
     */
    internal func locateAddress(addr: String, type: String) {
        let geocoder = CLGeocoder()
        
        // Get the address string
        geocoder.geocodeAddressString(addr,
            completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Error", error)
            }
            
            // Get the first hit
            if let placemark = placemarks?.first {
                let coordinates: CLLocationCoordinate2D =
                                                placemark.location!.coordinate
                
                // Create a region and pass it to the Map View
                var region = MKCoordinateRegion()
                region.center.latitude = coordinates.latitude;
                region.center.longitude = coordinates.longitude;
                region.span.latitudeDelta = 0.004;
                region.span.longitudeDelta = 0.004;
                
                // Create an annotation and also pass that
                let ann = MKPointAnnotation()
                ann.coordinate = coordinates
                ann.title = "Nearest \(type)"
                
                self.mapView.setRegion(region, animated: true)
                self.mapView.addAnnotation(ann)
            }
        })
    }
    
    // Has the resource changed, called as part of ResourceObserver
    func resourceChanged(resource: Resource, event: ResourceEvent) {
        
        // First check if we have the correct neighbourhood
        // details
        if neighbourhood?.latestData != nil {
            if case .NewData = event {
                // If we have new data then let's get some
                // contact details too
                getCDetailsFromAPI()
            }
        }
        
        // Otherwise we can now use the latest data from
        // contact details
        if contactDetails?.latestData != nil {
            
            // Obtain correct info
            let tel = contactDetails!.json["contact_details"]["telephone"].stringValue
            let email = contactDetails!.json["contact_details"]["email"].stringValue
            let addr = contactDetails!.json["locations"][0]["address"].stringValue
            let type = contactDetails!.json["locations"][0]["type"].stringValue
            
            // Add the nearest police station to map
            locateAddress(addr, type: type)
            
            // Update view's labels
            phoneLabel.text     = tel
            websiteLabel.text   = addr
            emailLabel.text     = email
            
            // Create the array of links
            if let items = contactDetails!.json["links"].array {
                self.links = []
                for item in items {
                    let url = item["url"].stringValue
                    let title = item["title"].stringValue
                    
                    let l = Link(url: url, title: title)
                    self.links.append(l)
                }
            }
            
        }
        
        self.tableView.reloadData()
    }


    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView,
        numberOfRowsInSection section: Int)
        -> Int {
        return self.links.count
    }
    
    // Here we are setting all the relevant fields and info
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath)
        -> UITableViewCell {
            
        let cell = tableView
            .dequeueReusableCellWithIdentifier("LinkCell",
                                                forIndexPath: indexPath)
            as UITableViewCell
            
        // Get the title from the Link object this row points to
        let title = self.links[indexPath.row].title
        
        // Set the title
        cell.textLabel?.text = title
        cell.backgroundColor = Style.viewBackground
        
        return cell
    }
    
    // Open up browser if clicked in a link
    func tableView(tableView: UITableView,
        didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let url = self.links[indexPath.row].url
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        // Force a call to the api that this resource points to, even
        // if loadIfNeeded() is called
        neighbourhood?.invalidate()
        neighbourhood?.removeObservers(ownedBy: self)
        contactDetails?.removeObservers(ownedBy: self)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
