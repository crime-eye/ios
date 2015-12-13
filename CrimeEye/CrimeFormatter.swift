//
//  CrimeFormatter.swift
//  CrimeEye
//
//  Created by Khen Cruzat on 13/12/2015.
//  Copyright © 2015 Crime Eye. All rights reserved.
//

import Foundation

class _CrimeFormatter {
    let crimeList = ["None", "anti-social-behaviour", "bicycle-theft"
        , "burglary", "criminal-damage-arson", "drugs", "other-crime"
        , "other-theft", "possession-of-weapons", "public-order", "robbery"
        , "shoplifting", "theft-from-the-person", "vehicle-crime"
        , "vehicle-theft", "violent-crime"]
    
    let categoryList = ["None", "Anti-social Behaviour", "Bicycle Theft"
        , "Burglary", "Criminal Damage Arson", "Drugs", "Other Crime"
        , "Other Theft", "Possession of Weapons", "Public Order", "Robbery"
        , "Shoplifting", "Theft from the Person", "Vehicle Crime"
        , "Vehicle Theft", "Violent Crime", "None"]
    
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