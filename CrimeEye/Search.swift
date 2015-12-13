//
//  Search.swift
//  CrimeEye
//
//  Created by Kieran Haden on 13/12/2015.
//  Copyright © 2015 Crime Eye. All rights reserved.
//

import UIKit
import MapKit

class Search: NSObject {
    
    var coordinate: CLLocationCoordinate2D
    var category: String?
    var street: String?
    var outcome: String?
    
    var url: NSURL?
    
    init(lat: Double, lon: Double, type: String, street: String, outcome: String) {
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        self.category = type
        self.street = street
        self.outcome = outcome
    }
}
