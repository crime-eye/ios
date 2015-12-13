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

class TutorialSecondViewController:
    UIViewController,
    CLLocationManagerDelegate,
    UITextFieldDelegate {
    
    let statusOverlay = ResourceStatusOverlay()
    
    // MARK: Outlets
    @IBOutlet var gpsSwitch: UISwitch!
    @IBOutlet weak var postcodeLabel: UILabel!
    @IBOutlet weak var postcodeField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusOverlay.embedIn(self)
        postcodeField.delegate = self
        postcodeField.textColor = Style.flatBlue3

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Handles gps switch behaviour
    @IBAction func switchChanged(sender: UISwitch) {
        // GPS switch on state
        if gpsSwitch.on {
            // Hide the postcode related views
            postcodeLabel.hidden = true
            postcodeField.hidden = true
            
            // update defaults to reflect GPS usage
            Store.defaults.setBool(true, forKey: Store.USE_GPS)
            
            if !GPS.couldBeLocatable() {
                let alertController = UIAlertController(
                    title: "Permission Error",
                    message: "Please allow Location permissions.",
                    preferredStyle: .Alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .Default,
                    handler: nil)
                alertController.addAction(defaultAction)
                
                presentViewController(alertController, animated: true,
                    completion: nil)

                return
            }
            
            if GPS.tryingToLocate {
                return
            }
            
            GPS.tryingToLocate = true
            GPS.startTime = nil
            
            GPS.locManager.desiredAccuracy = kCLLocationAccuracyBest
            GPS.locManager.activityType = .Fitness
            GPS.locManager.startUpdatingLocation()
        } else {
            // GPS switch off, change defaults and show postcode views
            Store.defaults.setBool(false, forKey: Store.USE_GPS)
            postcodeLabel.hidden = false
            postcodeField.hidden = false
            postcodeField.textColor = Style.flatBlue3
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        postcodeField.textColor = Style.flatBlue3
        return false
    }
    
    // OK button acts as save button
    @IBAction func clickedOK(sender: UIButton) {
        // Check gps switch state
        if (gpsSwitch.on){
            // only update if coordinates found
            if (PostcodesAPI.lat != 0.0){
                // Set user defaults to not show tutorial screen next time
                Store.defaults.setBool(true, forKey: Store.IS_FIRST_LOAD)
                // Save coordinates of GPS
                Store.defaults.setValue(PostcodesAPI.lat, forKey: Store.LAT)
                Store.defaults.setValue(PostcodesAPI.lng, forKey: Store.LONG)
                
                // Retrieve postcode from the coordinates
                PostcodesAPI.getPostcode(PostcodesAPI.lat,
                    lng: PostcodesAPI.lng).addObserver(owner: self) {
                    resource, event in
                    if case .NewData = event {
                        let result = resource.json["result"]
                        PostcodesAPI.postcode
                            = result[0]["postcode"].stringValue
                        
                        // Save the postcode
                        Store.defaults.setValue(PostcodesAPI.postcode,
                            forKey: Store.POST_CODE)
                        
                        // call the main screen
                        let app = UIApplication.sharedApplication()
                            .delegate as! AppDelegate
                        app.loadMainView()
                    }
                    }.addObserver(self.statusOverlay).load()
            }
                // if no coordinates found using GPS location
            else {
                let alertController = UIAlertController(
                    title: "GPS Error",
                    message: "Location cannot be pinpointed",
                    preferredStyle: .Alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .Default,
                    handler: nil)
                alertController.addAction(defaultAction)
                
                presentViewController(alertController, animated: true,
                    completion: nil)
            }
        }
        // if not using GPS
        else {
            // check for empty postcode field
            if (postcodeField.text!.isEmpty){
                let alertController = UIAlertController(title: "Postcode Empty",
                    message: "Please enter a valid postcode.",
                    preferredStyle: .Alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .Default,
                    handler: nil)
                alertController.addAction(defaultAction)
                
                presentViewController(alertController, animated: true,
                    completion: nil)
            }
            // postcode field not empty
            else {
                // make an api call to validate postcode
                PostcodesAPI.validatePostcode(postcodeField.text!)
                    .addObserver(owner: self) {
                    resource, event in
                    if case .NewData = event {
                        let valid = resource.json["result"]
                        // Valid postcode
                        if valid {
                            Store.defaults.setBool(true,
                                forKey: Store.IS_FIRST_LOAD)
                            // Change postcode to coordinates
                            PostcodesAPI.postcodeToLatAndLng(
                                self.postcodeField.text!)
                                .addObserver(owner: self) {
                                resource2, event in
                                if case .NewData = event {
                                    let result = resource2.json["result"]
                                    PostcodesAPI.lat
                                        = result["latitude"].doubleValue
                                    PostcodesAPI.lng
                                        = result["longitude"].doubleValue
                                    
                                    // Save coordinates to user defaults
                                    Store.defaults.setValue(PostcodesAPI.lat,
                                        forKey: Store.LAT)
                                    Store.defaults.setValue(PostcodesAPI.lng,
                                        forKey: Store.LONG)
                                    
                                    // Get correct postcode
                                    PostcodesAPI.getPostcode(PostcodesAPI.lat,
                                        lng: PostcodesAPI.lng)
                                        .addObserver(owner: self) {
                                        resource3, event in
                                        if case .NewData = event {
                                            let result
                                                = resource3.json["result"]
                                            PostcodesAPI.postcode
                                                = result[0]["postcode"]
                                                    .stringValue
                                            
                                            // save postcode to user defaults
                                            Store.defaults.setValue(
                                                PostcodesAPI.postcode,
                                                forKey: Store.POST_CODE)
                                            
                                            // Call main screen
                                            let app = UIApplication
                                                .sharedApplication().delegate
                                                        as! AppDelegate
                                            app.loadMainView()
                                        }
                                        }.addObserver(self.statusOverlay).load()
                                    
                                }
                                }.addObserver(self.statusOverlay).load()
                        }
                        // Invalid postcode
                        else {
                            let alertController = UIAlertController(
                                title: "Invalid Postcode",
                                message: "Please enter a valid postcode.",
                                preferredStyle: .Alert)
                            
                            let defaultAction = UIAlertAction(title: "OK",
                                style: .Default, handler: nil)
                            alertController.addAction(defaultAction)
                            
                            self.presentViewController(alertController,
                                animated: true, completion: nil)
                        }
                    }
                    }.addObserver(self.statusOverlay).load()
                
            }
        }
    }
    
}
