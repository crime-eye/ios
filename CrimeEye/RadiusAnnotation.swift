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
        var largest = 0
        var largestCrime = ""
        
        for (category, number) in counts {
            if number > largest {
                largestCrime = category
                largest = number
                
            }
        }
        let crimeList = ["anti-social-behaviour", "bicycle-theft", "burglary", "criminal-damage-arson", "drugs", "other-crime", "other-theft", "public-order", "robbery", "shoplifting", "theft-from-the-person", "vehicle-crime", "vehicle-theft", "violent-crime"]
        let colourList = [UIColor.blueColor(), UIColor.greenColor(), UIColor.redColor(), UIColor.cyanColor(), UIColor.darkGrayColor(), UIColor.yellowColor(), UIColor.flatForestGreenColor(), UIColor.flatLimeColor(), UIColor.flatOrangeColor(), UIColor.flatPinkColor(), UIColor.flatPurpleColor(),
            UIColor.flatPlumColor(),
        UIColor.flatPowderBlueColor(), UIColor.flatSandColor()]
        if crimeList.contains(largestCrime) {
            let i = crimeList.indexOf(largestCrime)
            return colourList[i!]
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
