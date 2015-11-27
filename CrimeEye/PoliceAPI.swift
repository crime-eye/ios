//
//  PoliceAPI.swift
//  CrimeEye
//
//  Created by Gurpreet Paul on 25/11/2015.
//  Copyright © 2015 Gurpreet Paul. All rights reserved.
//

import Siesta

class _PoliceAPI: Service {
    
    var lastUpdated: String = ""
    
    func getCrimes(lat: Double, long: Double) -> Resource {
        return resource("/crimes-street/all-crime")
                .withParam("lat", "\(lat)")
                .withParam("lng", "\(long)")
    }
    
    func getYearAndMonth(fullDate: String) -> String {
        let truncated = fullDate.characters.dropLast(3)
        return "\(truncated)"
    }
    
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

let PoliceAPI = _PoliceAPI()