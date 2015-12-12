//
//  Style.swift
//  CrimeEye
//
//  Created by Gurpreet Paul on 25/11/2015.
//  Copyright © 2015 Crime Eye. All rights reserved.
//

import Foundation
import ChameleonFramework

/**
 The Style struct enables us to store colours which
 make up the theme for the app. We can use the colours provided
 here to quickly provide consistency to the overall GUI
 of the app.
 */
struct Style {
    
    // Blue colours
    static var flatBlue1 = UIColor(hexString: "72B0D9")
    static var flatBlue2 = UIColor(hexString: "4995C7")
    static var flatBlue3 = UIColor(hexString: "2980b9")
    static var flatBlue4 = UIColor(hexString: "096EB0")
    static var flatBlue5 = UIColor(hexString: "07507F")
    
    // Gold colours
    static var flatGold1 = UIColor(hexString: "FFDE7F")
    static var flatGold2 = UIColor(hexString: "FFD253")
    static var flatGold3 = UIColor(hexString: "FFC82C")
    static var flatGold4 = UIColor(hexString: "FFBC00")
    static var flatGold5 = UIColor(hexString: "C79300")
    
    // Red colours
    static var flatRed1 = UIColor(hexString: "FFA07F")
    static var flatRed2 = UIColor(hexString: "FF7F53")
    static var flatRed3 = UIColor(hexString: "FF622C")
    static var flatRed4 = UIColor(hexString: "FF4100")
    static var flatRed5 = UIColor(hexString: "C73300")

    static var white = UIColor.whiteColor()

    // Navbar
    static var navbarBackground = flatBlue3
    static var navbarTextColor  = white
    static var viewBackground   = white
    static var warningColor     = flatRed5
    
    // General
    static var sectionHeaders   = flatGold4
    static var fontColor        = flatBlue3
    
    // Line chart
    static var circleColor      = flatBlue1
    
    // Page view controllers
    static var pageControlDotNormal   = UIColor.grayColor()
    static var pageControlDotHighlighted   = flatBlue3
}