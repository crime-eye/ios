//
//  PoliceAPI.swift
//  CrimeEye
//
//  Created by Gurpreet Paul on 25/11/2015.
//  Copyright © 2015 Crime Eye. All rights reserved.
//

import Siesta

/**
 _PoliceAPI defines the main API that we use
 to extract data from and display that data in the app.
 */

class _PoliceAPI: Service {
    
    var lastUpdated = ""
    
    /**
     Get a list of street level crimes.
     - parameters:
       - lat: Latitude of the user's current location.
       - long: Longitude of the user's current location.
     - returns: A Resource to monitor the full list of crimes.
     */
    func getCrimes(lat: Double, long: Double) -> Resource {
        return resource("/crimes-street/all-crime")
                .withParam("lat", "\(lat)")
                .withParam("lng", "\(long)")
    }
    
    /**
     Get outcomes at a location and in a specific month.
     - parameters:
        - date: Date in YYYY-MM format.
        - lat: Latitude of the user's current location.
        - long: Longitude of the user's current location.
     - returns: A Resource to monitor the full list of outcomes.
     */
    func getOutcomes(date: String, lat: Double, long: Double) -> Resource {
        return resource("/outcomes-at-location")
            .withParam("date", date)
            .withParam("lat", "\(lat)")
            .withParam("lng", "\(long)")
    }
    
    /**
     From a full date (YYYY-MM-DD) strip the last 3 characters.
     - parameters:
        - fullDate: Latitude of the user's current location.
     - returns: A string of the form YYYY-MM
     */
    func getYearAndMonth(fullDate: String) -> String {
        let truncated = fullDate.characters.dropLast(3)
        return "\(truncated)"
    }
    
    /**
     When was the API last updated?
     - returns: A Resource that holds when the 
     last updated date was.
     */
    func getLastUpdated() -> Resource {
        return resource("/crime-last-updated")
    }
    
    
    func getCrimesLastUpdated(lastUpdated: String) -> Resource {
        return resource("/crime-last-updated")
    }
    
    
    init() {
        super.init(base: "https://data.police.uk/api")
        self.getLastUpdated()
    }
    
}

// Here we define PoliceAPI which will mean it will 
// be available across the app
let PoliceAPI = _PoliceAPI()