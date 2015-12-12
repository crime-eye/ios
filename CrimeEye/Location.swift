//
//  Location.swift
//  CrimeEye
//
//  Created by Khen Cruzat on 26/11/2015.
//  Copyright © 2015 Gurpreet Paul. All rights reserved.
//

import MapKit

class Location: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var category: String?
    var month: String!
    var street: String!
    var outcome: String!
    
    var url: NSURL?
    
    init(lat: Double, lon: Double, category: String!, month: String!, street: String!, outcome: String!) {
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        self.category = category!
        self.month = month
        self.street = street
        self.outcome = outcome
    }
    
    var title: String? {
        return category
    }
    
    var subtitle: String? {
        return month
    }
    
}
