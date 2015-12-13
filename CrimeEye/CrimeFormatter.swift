//
//  CrimeFormatter.swift
//  CrimeEye
//
//  Created by Khen Cruzat on 13/12/2015.
//  Copyright © 2015 Crime Eye. All rights reserved.
//

import Foundation

class _CrimeFormatter {
    let crimeList = ["anti-social-behaviour", "bicycle-theft", "burglary"
        , "criminal-damage-arson", "drugs", "other-crime", "other-theft"
        , "public-order", "robbery", "shoplifting", "theft-from-the-person"
        , "vehicle-crime", "vehicle-theft", "violent-crime"]
    
    let categoryList = ["Anti-social Behaviour", "Bicycle Theft", "Burglary"
        , "Criminal Damage Arson", "Drugs", "Other Crime", "Other Theft"
        , "Public Order", "Robbery", "Shoplifting", "Theft from the Person"
        , "Vehicle Crime", "Vehicle Theft", "Violent Crime"]
    
    let monthName = ["January", "February", "March", "April", "May", "June"
        , "July", "August", "September", "October", "November", "December"]
    
    func formatCat(cat: String) -> String {
        if let i = crimeList.indexOf(cat){
            return categoryList[i]
        }
        return ""
    }
    
    func formatDate(date: String) -> String{
        let dateArr = date.componentsSeparatedByString("-")
        let month = Int(dateArr[1])
        
        return "\(monthName[month!-1])"
    }

}

let CrimeFormatter = _CrimeFormatter()