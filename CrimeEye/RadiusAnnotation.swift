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
    var crimeType = ""
    var colour: UIColor {
        var counts = [String: Int]()
        for location in locArray {
            if crimeType == "crimes" {
                let loc = location as? Location
                counts[loc!.category!] = (counts[loc!.category!] ?? 0) + 1
            }
            if crimeType == "searches" {
                let search = location as? Search
                counts[search!.category!] = (counts[search!.category!] ?? 0) + 1
            }
        }
        var largest = 0
        var largestCrime = ""
        
        for (category, number) in counts {
            if number > largest {
                largestCrime = category
                largest = number
                
            }
        }
        let colourList = [UIColor.greenColor(), UIColor.blueColor(),
            UIColor.flatRedColorDark(),UIColor.redColor(), UIColor.cyanColor(),
            UIColor.darkGrayColor(),UIColor.yellowColor(),
            UIColor.flatForestGreenColor(),UIColor.flatLimeColor(),
            UIColor.flatOrangeColor(),UIColor.flatPinkColor(),
            UIColor.flatPurpleColor(),UIColor.flatPlumColor(),
            UIColor.flatPowderBlueColor(),UIColor.flatSandColor(),
            UIColor.flatMaroonColorDark()]
        if crimeType == "crimes" && CrimeFormatter.crimeList.contains(largestCrime) {
            let i = CrimeFormatter.crimeList.indexOf(largestCrime)
            return colourList[i!]
        }
        if crimeType == "searches" && CrimeFormatter.searchList.contains(largestCrime) {
            let i = CrimeFormatter.searchList.indexOf(largestCrime)
            return colourList[i!]
        }
        else {
            return UIColor.flatBlueColorDark()
        }
    }
    var radiusSize: Double {
        return 10+(2*crimeNumber * 1.0/exp(0.1*pow(crimeNumber,0.01)))
    }
    var coordinate: CLLocationCoordinate2D
    var locArray: [AnyObject?] = []
    
    init(coordinate: CLLocationCoordinate2D, crimeType: String) {
        self.coordinate = coordinate
        self.crimeType = crimeType
        super.init()
    }
    
    var title: String? {
        return "View Crimes"
    }
    
    var subtitle: String? {
        return ""
    }
    
    func addLocation(loc: AnyObject)
    {
        locArray.append(loc)
        crimeNumber = crimeNumber + 1.0
    }
}
