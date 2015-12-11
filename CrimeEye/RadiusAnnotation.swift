//
//  RadiusAnnotation.swift
//  CrimeEye
//
//  Created by Kieran Haden on 03/12/2015.
//  Copyright © 2015 Crime Eye. All rights reserved.
//

import MapKit

class RadiusAnnotation: NSObject, MKAnnotation {
    
    var crimeNumber = 1.0;
    var colour: UIColor {
        var counts = [String: Int]()
        for location in locArray {
            counts[location.category!] = (counts[location.category!] ?? 0) + 1
        }
        let largest = 0
        var largestCrime = ""
        
        for (category, number) in counts {
            if number > largest {
                largestCrime = category
            }
        }
        if (largestCrime == "violent-crime") {
            return UIColor.blueColor()
        }
        if (largestCrime == "public-order") {
            return UIColor.greenColor()
        }
        if (largestCrime == "anti-social-behaviour") {
            return UIColor.redColor()
        }
        if (largestCrime == "burglary") {
            return UIColor.blackColor()
        }
        if (largestCrime == "shoplifting") {
            return UIColor.cyanColor()
        }
        if (largestCrime == "bicycle-theft") {
            return UIColor.darkGrayColor()
        }
        if (largestCrime == "burglary") {
            return UIColor.grayColor()
        }
        if (largestCrime == "burglary") {
            return UIColor.yellowColor()
        }
        if (largestCrime == "other-theft") {
            return UIColor.flatForestGreenColor()
        }
        if (largestCrime == "vehicle-crime") {
            return UIColor.flatLimeColor()
        }
        if (largestCrime == "vehicle-theft") {
            return UIColor.flatOrangeColor()
        }
        if (largestCrime == "theft-from-the-person") {
            return UIColor.flatPinkColor()
        }
        if (largestCrime == "criminal-damage-arson") {
            return UIColor.flatPurpleColor()
        }
        else {
            return UIColor.flatWhiteColor()
        }
    }
    var radiusSize: Double {
        return 10+(2*crimeNumber * 1.0/exp(0.1*pow(crimeNumber,0.01)))
    }
    var coordinate: CLLocationCoordinate2D
    var locArray: [Location] = []
    
    init(coordinate: CLLocationCoordinate2D, location: Location) {
        self.coordinate = coordinate
        self.locArray.append(location)
        super.init()
    }
    
    var title: String? {
        return "View Crimes"
    }
    
    var subtitle: String? {
        return ""
    }
    
    func addLocation(loc: Location)
    {
        locArray.append(loc)
        crimeNumber = crimeNumber + 1.0
    }
}
