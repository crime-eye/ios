//
//  TutorialSecondViewController.swift
//  CrimeEye
//
//  Created by Gurpreet Paul on 03/12/2015.
//  Copyright © 2015 Crime Eye. All rights reserved.
//

import UIKit
import CoreLocation
import Siesta
import Foundation

class TutorialSecondViewController: UIViewController, CLLocationManagerDelegate {
    
    let statusOverlay = ResourceStatusOverlay()
    
    let requiredAccuracy: CLLocationAccuracy = 100.0
    let maxTime: NSTimeInterval = 10
    
    var locManager = CLLocationManager()
    
    var tryingToLocate = false
    var startTime: NSDate?

    @IBOutlet var gpsSwitch: UISwitch!
    @IBOutlet weak var postcodeLabel: UILabel!
    @IBOutlet weak var postcodeField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusOverlay.embedIn(self)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func switchChanged(sender: UISwitch) {
        if gpsSwitch.on {
            postcodeLabel.hidden = true
            postcodeField.hidden = true
            
            Store.defaults.setBool(true, forKey: Store.USE_GPS)
            if !couldBeLocatable() {
                print("Not authorized!")
                return
            }
            
            if tryingToLocate {
                return
            }
            
            tryingToLocate = true
            startTime = nil
            
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyBest
            locManager.activityType = .Fitness
            locManager.startUpdatingLocation()
        } else {
            Store.defaults.setBool(false, forKey: Store.USE_GPS)
            postcodeLabel.hidden = false
            postcodeField.hidden = false
        }
    }

    @IBAction func clickedOK(sender: UIButton) {
        if (gpsSwitch.on){
            if (PostcodesAPI.lat != 0.0){
                Store.defaults.setBool(true, forKey: Store.IS_FIRST_LOAD)
                Store.defaults.setValue(PostcodesAPI.lat, forKey: Store.LAT)
                Store.defaults.setValue(PostcodesAPI.lng, forKey: Store.LONG)
                PostcodesAPI.getPostcode(PostcodesAPI.lat, lng: PostcodesAPI.lng).addObserver(owner: self) {
                    resource, event in
                    if case .NewData = event {
                        let result = resource.json["result"]
                        PostcodesAPI.postcode = result[0]["postcode"].stringValue
                        Store.defaults.setValue(PostcodesAPI.postcode, forKey: Store.POST_CODE)
                        
                        let app = UIApplication.sharedApplication().delegate as! AppDelegate
                        app.loadMainView()
                    }
                }.addObserver(self.statusOverlay).load()
            }
            else {
                let alertController = UIAlertController(title: "Permission Error", message: "Please allow Location permissions to use locations services.", preferredStyle: .Alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(defaultAction)
                
                presentViewController(alertController, animated: true, completion: nil)
            }
        }
        else {
            if (postcodeField.text!.isEmpty){
                let alertController = UIAlertController(title: "Postcode Empty", message: "Please enter a valid postcode.", preferredStyle: .Alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alertController.addAction(defaultAction)
                
                presentViewController(alertController, animated: true, completion: nil)
            }
            else {
                PostcodesAPI.validatePostcode(postcodeField.text!).addObserver(owner: self) {
                    resource, event in
                    if case .NewData = event {
                        let valid = resource.json["result"]
                        if valid {
                            Store.defaults.setBool(true, forKey: Store.IS_FIRST_LOAD)
                            PostcodesAPI.postcodeToLatAndLng(self.postcodeField.text!).addObserver(owner: self) {
                                resource2, event in
                                if case .NewData = event {
                                    let result = resource2.json["result"]
                                    PostcodesAPI.lat = result["latitude"].doubleValue
                                    PostcodesAPI.lng = result["longitude"].doubleValue
                                    Store.defaults.setValue(PostcodesAPI.lat, forKey: Store.LAT)
                                    Store.defaults.setValue(PostcodesAPI.lng, forKey: Store.LONG)
                                    
                                    PostcodesAPI.getPostcode(PostcodesAPI.lat, lng: PostcodesAPI.lng).addObserver(owner: self) {
                                        resource3, event in
                                        if case .NewData = event {
                                            let result = resource3.json["result"]
                                            PostcodesAPI.postcode = result[0]["postcode"].stringValue
                                            Store.defaults.setValue(PostcodesAPI.postcode, forKey: Store.POST_CODE)
                                            
                                            let app = UIApplication.sharedApplication().delegate as! AppDelegate
                                            app.loadMainView()
                                        }
                                    }.addObserver(self.statusOverlay).load()
                                    
                                }
                            }.addObserver(self.statusOverlay).load()
                        }
                        else {
                            let alertController = UIAlertController(title: "Invalid Postcode", message: "Please enter a valid postcode.", preferredStyle: .Alert)
                            
                            let defaultAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                            alertController.addAction(defaultAction)
                            
                            self.presentViewController(alertController, animated: true, completion: nil)
                        }
                    }
                }.addObserver(self.statusOverlay).load()
                
            }
        }
    }
    
    func couldBeLocatable() -> Bool {
        
        if !CLLocationManager.locationServicesEnabled() {
            // Location services not enabled but might be in future
            return true
        }
        
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            return true
        case .NotDetermined:
            // Ask user for permission
            locManager.requestWhenInUseAuthorization()
            return true
        case .Restricted, .Denied:
            return false
        }
    }
    
    func stopTrying() {
        locManager.stopUpdatingLocation()
        startTime = nil
        tryingToLocate = false
    }
    
    // Handle updates to location
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("Updated location")
        
        if startTime == nil {
            // Ignore first sample because it probably isn't very accurate
            print("Ignoring first sample")
            startTime = NSDate()
            return
        }
        
        let location = locations.last! as CLLocation
        
        let time = location.timestamp
        let elapsed = time.timeIntervalSinceDate(startTime!)
        if elapsed > maxTime {
            print("This is taking too long")
            stopTrying()
            return
        }
        
        let accuracy = location.horizontalAccuracy
        print("Accuracy = \(accuracy)")
        if accuracy < 0 || accuracy > requiredAccuracy {
            print("Accuracy not good enough - waiting for next sample")
            return
        }
        
        let coord = location.coordinate
        let lat = coord.latitude
        let lon = coord.longitude
        PostcodesAPI.lat = lat
        PostcodesAPI.lng = lon
        print("\(lat, lon)")
        
        stopTrying()
    }
    
    // Handle errors
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Failed: \(error)")
        stopTrying()
    }
}
