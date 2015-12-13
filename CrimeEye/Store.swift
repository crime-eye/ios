//
//  Store.swift
//  CrimeEye
//
//  Created by Gurpreet Paul on 03/12/2015.
//  Copyright © 2015 Crime Eye. All rights reserved.
//

import Foundation

/**
 Store acts like a NSUserDefaults wrapper. 
 In here you will find keys that define
 how to extract data from NSUserDefaults.
 */

class Store {
    /// Use this for a quick handle on NSUserDefaults
    static let defaults = NSUserDefaults.standardUserDefaults()
    
    /// Does the user want to use GPS?
    static let USE_GPS = "USE_GPS"
    
    /// Is it the app's first ever load?
    static let IS_FIRST_LOAD = "FIRST_LOAD"
    
    /// If not using GPS what's the postcode?
    static let POST_CODE = "POST_CODE"
    
    /// Latitude of the user
    static let LAT = "LAT"
    
    /// Longitude of the user
    static let LONG = "LONG"
    
    /// Stores the neighbourhood force
    static let FORCE = "NEIGHBOURHOOD_FORCE"
    
    /// Stores the regional neighbourhood of the user
    static let NBOURHOOD = "NEIGHBOURHOOD"
}