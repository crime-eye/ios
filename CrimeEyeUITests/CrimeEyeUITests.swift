//
//  CrimeEyeUITests.swift
//  CrimeEyeUITests
//
//  Created by Gurpreet Paul on 21/11/2015.
//  Copyright © 2015 Gurpreet Paul. All rights reserved.
//

import XCTest


// MAKE SURE LOCATION PERMISSION HAVE BEEN GIVEN FIRST
class CrimeEyeUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // Test opening crime map and changing postcode
    func testMapPostcode() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCUIDevice.sharedDevice().orientation = .Portrait
        
        let app = XCUIApplication()
        app.navigationBars["Main"].buttons["Menu 100"].tap()
        app.tables.staticTexts["CRIME"].tap()
        app.buttons["Change postcode"].tap()
        
        let collectionViewsQuery = app.alerts["Change postcode"].collectionViews
        collectionViewsQuery.textFields["Enter postcode"].typeText("ls29jt")
        
        let confirmButton = collectionViewsQuery.buttons["Confirm"]
        confirmButton.tap()
    }
    
    // Test opening cime map and changing filter
    func testMapFilter(){
        XCUIDevice.sharedDevice().orientation = .Portrait
        
        let app = XCUIApplication()
        app.navigationBars["Main"].buttons["Menu 100"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.staticTexts["CRIME"].tap()
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Other).element.childrenMatchingType(.Button).matchingIdentifier("Filter by").elementBoundByIndex(1).tap()
        tablesQuery.staticTexts["Burglary"].tap()
        app.buttons["Filter"].tap()
    }
    
    // Test opening Settings screen and change postcode
    func testSettings1Postcode() {
        XCUIDevice.sharedDevice().orientation = .Portrait
        
        let app = XCUIApplication()
        app.navigationBars["Main"].buttons["Menu 100"].tap()
        app.buttons[" SETTINGS"].tap()
        
        if app.switches["1"].exists {
            app.switches["1"].tap()
        }
        else {
            app.switches["0"].tap()
            app.switches["1"].tap()
        }
        
        app.textFields["Enter here"].tap()
        app.textFields["Enter here"].tap()
        
        let selectAllMenuItem = app.menuItems["Select All"]
        selectAllMenuItem.tap()
        
        app.textFields["Enter here"].typeText("ls53eh")
        app.buttons["Return"].tap()
    
        app.buttons["OK"].tap()
        
        // Make sure postcode was set
        let postcodeLabel = app.staticTexts.elementMatchingType(.Any, identifier: "postcodeLabel").label
         XCTAssertEqual(postcodeLabel, "in LS5 3EH", "found instead: \(postcodeLabel.debugDescription)")
    }
    
    // Test opening Settings screen and use GPS
    func testSettings2GPS(){
        XCUIDevice.sharedDevice().orientation = .Portrait
        
        let app = XCUIApplication()
        app.navigationBars["Main"].buttons["Menu 100"].tap()
        app.buttons[" SETTINGS"].tap()
        
        if app.switches["0"].exists {
            app.switches["0"].tap()
        }
        else{
            app.switches["1"].tap()
            app.switches["0"].tap()
        }

        app.buttons["OK"].tap()
      
        
    }
    
    // Test refresh button in the main screen
    func testMainRefresh(){
        XCUIDevice.sharedDevice().orientation = .Portrait
        
        let app = XCUIApplication()
        
        let postcodeLabel = app.staticTexts.elementMatchingType(.Any, identifier: "postcodeLabel").label

        app.navigationBars["Main"].buttons["Refresh"].tap()
        
        let postcodeLabel2 = app.staticTexts.elementMatchingType(.Any, identifier: "postcodeLabel").label
        
        XCTAssertEqual(postcodeLabel, postcodeLabel2, "found instead: \(postcodeLabel2.debugDescription)")

    }
    
    // Test Neighbourhood screen and open a link from Contact screen
    func testNeighbour(){
        XCUIDevice.sharedDevice().orientation = .Portrait
        
        let app = XCUIApplication()
        app.navigationBars["Main"].buttons["Menu 100"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.staticTexts["NEIGHBOURHOOD"].tap()
        
        app.tables.elementBoundByIndex(1).tap()

    }
    
    // Test the Neighbourhood screen and open the priorities screen
    func testPriorities(){
        XCUIDevice.sharedDevice().orientation = .Portrait
        
        let app = XCUIApplication()
        app.navigationBars["Main"].buttons["Menu 100"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.staticTexts["NEIGHBOURHOOD"].tap()
        
        app.tabBars.buttons["Priorities"].tap()

    }
    
}
