//
//  MapViewController.swift
//  CrimeEye
//
//  Created by Khen Cruzat on 22/11/2015.
//  Copyright © 2015 Gurpreet Paul. All rights reserved.
//

import UIKit
import MapKit
import Foundation
import MMDrawerController
import Siesta

class MapViewController: UIViewController, MKMapViewDelegate, ResourceObserver {
    
    typealias CrimeDict = Dictionary<String, AnyObject>
    var crimesArray: [CrimeDict] = []
    
    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
    }
    
    internal func setupMapView() {
        self.mapView.delegate = self
        self.mapView.mapType = .Standard
        self.mapView.pitchEnabled = false
        
        let lat = PostcodesAPI.lat
        let lng = PostcodesAPI.lng
        
        // Set the map region
        let location = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let region = MKCoordinateRegionMakeWithDistance(location, 1500.0, 1500.0)
        self.mapView.setRegion(region, animated: true)
    }
    
    // If the map has finished loading....
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
    
        let lat = PostcodesAPI.lat
        let lng = PostcodesAPI.lng
        
        PoliceAPI
            .getCrimes(lat, long: lng)
            .addObserver(self)
            .loadIfNeeded()
    }

    
    func resourceChanged(resource: Resource, event: ResourceEvent) {
        if (resource.latestData != nil) {
            let jsonArray = resource.json
            
            // iterate over all the crimes
            for (_, crimes) in jsonArray {
                
                let crimeLoc = crimes["location"]
                
                let month       = crimes["month"].stringValue
                let cat         = crimes["category"].stringValue
                let lat         = crimeLoc["latitude"].doubleValue
                let lng         = crimeLoc["longitude"].doubleValue
                let street      = crimeLoc["street"]["name"].stringValue
                
                
                // store information on each crime
                let crimeDict = self.crimeToDict(month,
                    category: cat,
                    lat: lat,
                    lng: lng,
                    street: street)
                
                self.crimesArray.append(crimeDict)
                
                let loc = Location(lat: lat,
                    lon: lng,
                    category: cat,
                    month: month,
                    street: street)
                
                // add each crime to the map as an annotation
                self.mapView.addAnnotation(loc)
                resource.removeObservers(ownedBy: self)
            }
            
        }

    }
    
    internal func crimeToDict(month: String,
                    category: String,
                    lat: Double,
                    lng: Double,
                    street: String) -> CrimeDict {
            
        var crimeDict = [String: AnyObject]()
        crimeDict["month"]       = month
        crimeDict["category"]    = category
        crimeDict["latitude"]    = lat
        crimeDict["longitude"]   = lng
        crimeDict["street"]      = street
        
        return crimeDict
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func openDrawer(sender: UIBarButtonItem) {
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }

}
