//
//  GPS.swift
//  CrimeEye
//
//  Created by Khen Cruzat on 13/12/2015.
//  Copyright © 2015 Crime Eye. All rights reserved.
//

import Foundation
import CoreLocation

class _GPS: NSObject, CLLocationManagerDelegate {
    let requiredAccuracy: CLLocationAccuracy = 100.0
    let maxTime: NSTimeInterval = 10
    
    var locManager = CLLocationManager()
    
    var tryingToLocate = false
    var startTime: NSDate?
    
    func couldBeLocatable() -> Bool {
        locManager.delegate = self
        
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

let GPS = _GPS()