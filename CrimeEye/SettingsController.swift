//
//  SettingsController.swift
//  CrimeEye
//
//  Created by Khen Cruzat on 12/12/2015.
//  Copyright © 2015 Crime Eye. All rights reserved.
//

import UIKit
import CoreLocation
import Siesta
import Foundation
import MMDrawerController

class SettingsController: UIViewController, CLLocationManagerDelegate,
                            UITextFieldDelegate {
    let statusOverlay = ResourceStatusOverlay()
    
    // MARK: Outlets
    @IBOutlet var gpsSwitch: UISwitch!
    @IBOutlet weak var postcodeLabel: UILabel!
    @IBOutlet weak var postcodeField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusOverlay.embedIn(self)
        self.postcodeField.delegate = self
        
        // Set colours for some views
        view.backgroundColor = Style.viewBackground
        postcodeField.textColor = Style.flatBlue3
        postcodeField.text = PostcodesAPI.postcode
        
        // Change GPS switch to reflect user defaults
        if ( Store.defaults.boolForKey(Store.USE_GPS)){
            gpsSwitch.setOn(true, animated: false)
            postcodeField.hidden = true
            postcodeLabel.hidden = true
        }
        else {
            gpsSwitch.setOn(false, animated: false)
            postcodeField.textColor = Style.flatBlue3
            
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openDrawer(sender: UIBarButtonItem) {
        let appDelegate:AppDelegate
        = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.centerContainer!.toggleDrawerSide(MMDrawerSide.Left
            , animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        postcodeField.textColor = Style.flatBlue3
        return false
    }
    
    // When GPS switch is toggled
    @IBAction func switchChanged(sender: UISwitch) {
        // if GPS enabled, set user defaults and start to use GPS
        if gpsSwitch.on {
            postcodeLabel.hidden = true
            postcodeField.hidden = true
            
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
            Store.defaults.setBool(false, forKey: Store.USE_GPS)
            postcodeLabel.hidden = false
            postcodeField.hidden = false
            postcodeField.textColor = Style.flatBlue3
        }
    }
    
    // When clicked OK, save settings
    @IBAction func clickedOK(sender: UIButton) {
        // check if GPS is enabled
        if (gpsSwitch.on){
            if (PostcodesAPI.lat != 0.0){
                // save coordinates found from GPS
                Store.defaults.setValue(PostcodesAPI.lat, forKey: Store.LAT)
                Store.defaults.setValue(PostcodesAPI.lng, forKey: Store.LONG)
                
                // get the postcode using this coordinates and save it
                PostcodesAPI.getPostcode(PostcodesAPI.lat
                    , lng: PostcodesAPI.lng).addObserver(owner: self) {
                        resource, event in
                        if case .NewData = event {
                            let result = resource.json["result"]
                            PostcodesAPI.postcode
                                = result[0]["postcode"].stringValue
                            Store.defaults.setValue(PostcodesAPI.postcode
                                , forKey: Store.POST_CODE)
                            
                            // force to reload main screen and open it
                            PoliceAPI.monthArray = []
                            PoliceAPI.crimesArray = []
                            PoliceAPI.outcomesDict = [String:[String]]()
                            let app = UIApplication.sharedApplication().delegate
                                as! AppDelegate
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
            // If not using GPS
        else {
            // Check if postcode field is empty
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
                // make api call to validate postcode
                PostcodesAPI.validatePostcode(postcodeField.text!)
                .addObserver(owner: self) {
                resource, event in
                if case .NewData = event {
                    let valid = resource.json["result"]
                    
                    // Postcode is valid
                    if valid {
                        
                        // Convert postcode to coordinates
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
                                    
                                    //Save coordinates
                                    Store.defaults.setValue(
                                        PostcodesAPI.lat, forKey: Store.LAT)
                                    Store.defaults.setValue(
                                        PostcodesAPI.lng, forKey: Store.LONG)
                                    
                                    // get postcode in proper formatting
                                    PostcodesAPI.getPostcode(PostcodesAPI.lat
                                        , lng: PostcodesAPI.lng)
                                        .addObserver(owner: self) {
                                        resource3, event in
                                        if case .NewData = event {
                                            let result
                                            = resource3.json["result"]
                                            PostcodesAPI.postcode =
                                             result[0]["postcode"].stringValue
                                            
                                            // Save postcode
                                            Store.defaults.setValue(
                                                PostcodesAPI.postcode
                                                , forKey: Store.POST_CODE)
                                            
                                            // Force to reload main screen
                                            PoliceAPI.monthArray = []
                                            PoliceAPI.crimesArray = []
                                            PoliceAPI.outcomesDict
                                                = [String:[String]]()
                                            let app =
                                            UIApplication
                                                .sharedApplication()
                                                .delegate as! AppDelegate
                                            app.loadMainView()
                                            }
                                        }.addObserver(self.statusOverlay).load()
                                    
                                }
                            }.addObserver(self.statusOverlay).load()
                    }
                        // if invalid postcode
                    else {
                        let alertController = UIAlertController(
                            title: "Invalid Postcode"
                            , message: "Please enter a valid postcode.",
                            preferredStyle: .Alert)
                        
                        let defaultAction = UIAlertAction(title: "OK"
                            , style: .Default, handler: nil)
                        alertController.addAction(defaultAction)
                        
                        self.presentViewController(alertController
                            , animated: true, completion: nil)
                    }
                }
            }.addObserver(self.statusOverlay).load()
            
            }
        }
    }
    
}


