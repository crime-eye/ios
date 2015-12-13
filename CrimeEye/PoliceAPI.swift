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
    var monthArray = [String]()
    var outcomesDict = [String:[String]]()
    
    typealias CrimeDict = Dictionary<String, AnyObject>
    var crimesArray: [CrimeDict] = []
        
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
    
    /**
     Locate the user's neighbourhood.
     - parameters:
        - lat: Latitude of the user's current location.
        - lng: Longitude of the user's current location.
     - returns: JSON object with force and neighbourhood.
     */
    func locateNeighbourhood(lat: Double, lng: Double) -> Resource {
        return resource("/locate-neighbourhood")
            .withParam("q", "\(lat),\(lng)")
    }
    
    /**
     Gets the contact details of a neighbourhood team.
     - parameters:
        - force: The regional police force of the user.
        - neighbourhoodCode: The local neighbourhood code of the user.
     - returns: JSON object with contact_details and more information.
     */
    func getContactDetails(force: String, neighbourhoodCode: String) -> Resource {
        return resource("/")
            .child(force)
            .child(neighbourhoodCode)
    }
    
    /**
     Get what the neighbourhood team is doing.
     - parameters:
        - force: The regional police force of the user.
        - neighbourhoodCode: The local neighbourhood code of the user.
     - returns: JSON array of list of dictionaries. Each dict is a priority.
     */
    func getPriorities(force: String, neighbourhoodCode: String) -> Resource {
        return resource("/")
            .child(force)
            .child(neighbourhoodCode)
            .child("priorities")
    }
    
    
    init() {
        super.init(base: "https://data.police.uk/api")
        self.getLastUpdated()
    }
    
}

// Here we define PoliceAPI which will mean it will 
// be available across the app
let PoliceAPI = _PoliceAPI()