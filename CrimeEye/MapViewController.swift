//
//  MapViewController.swift
//  CrimeEye
//
//  Created by Khen Cruzat on 22/11/2015.
//  Copyright © 2015 Gurpreet Paul. All rights reserved.
//

import UIKit
import MapKit
import SwiftyJSON
import Foundation
import MMDrawerController

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var crimesArray: [Dictionary<String,String>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: Outlets
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.mapType = .Standard
            mapView.pitchEnabled = false
            // Call to API to convert postcode to coordinates
            PostcodesAPI.lookupPostcode("LS29JT").addObserver(owner: self, closure: {resource, event in
                if (resource.latestData != nil) {
                    let result = resource.json["result"]
                    let lat = Double(result["latitude"].rawString()!)!
                    let long = Double(result["longitude"].rawString()!)!
                    // Set the map region
                    let location = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    let region = MKCoordinateRegionMakeWithDistance(location, 800.0, 800.0)
                    self.mapView.setRegion(region, animated: true)
                    
                    // Using the coordinates, find crimes in the area
                    PoliceAPI.getCrimes(String(lat),long: String(long)).addObserver(owner: self, closure: {resource, event in
                        if (resource.latestData != nil) {
                            let jsonArray = resource.json
                            for (_,crimes) in jsonArray{    // iterate over all the crimes
                                var crimeDic = [String:String]()
                                
                                let crimeLoc = crimes["location"]
                                // store information on each crime
                                crimeDic["month"] = crimes["month"].rawString()!
                                crimeDic["category"] = crimes["category"].rawString()!
                                crimeDic["latitude"] = crimeLoc["latitude"].rawString()!
                                crimeDic["longitude"] = crimeLoc["longitude"].rawString()!
                                crimeDic["street"] = crimeLoc["street"]["name"].rawString()!
                                
                                self.crimesArray.append(crimeDic)
                                // add each crime to the map as an annotation
                                self.mapView.addAnnotation(Location(lat: Double(crimeDic["latitude"]!)!, lon: Double(crimeDic["longitude"]!)!,
                                    category: crimeDic["category"]!, month: crimeDic["month"]!, street: crimeDic["street"]!))
                                
                            }
                            self.mapView.delegate = self
                        }
                    }).loadIfNeeded()
                }
            }).loadIfNeeded()
        }
    }
    
    @IBAction func openDrawer(sender: UIBarButtonItem) {
        let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }

}
