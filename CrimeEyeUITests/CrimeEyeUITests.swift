//
//  CrimeEyeUITests.swift
//  CrimeEyeUITests
//
//  Created by Gurpreet Paul on 21/11/2015.
//  Copyright © 2015 Gurpreet Paul. All rights reserved.
//

import XCTest


// MAKE SURE GPS IS TURNED ON IN THE APP BEFORE RUNNING TESTS
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
    
    func testSettings1Postcode() {
        XCUIDevice.sharedDevice().orientation = .Portrait
        
        let app = XCUIApplication()
        app.navigationBars["Main"].buttons["Menu 100"].tap()
        app.buttons[" SETTINGS"].tap()
        
        app.switches["1"].tap()
        app.textFields["Enter here"].tap()
        app.textFields["Enter here"].tap()
        
        let selectAllMenuItem = app.menuItems["Select All"]
        selectAllMenuItem.tap()
        
        app.textFields["Enter here"].typeText("ls53eh")
        app.buttons["Return"].tap()
    
        app.buttons["OK"].tap()
        
        let postcodeLabel = app.staticTexts.elementMatchingType(.Any, identifier: "postcodeLabel").label
         XCTAssertEqual(postcodeLabel, "in LS5 3EH", "found instead: \(postcodeLabel.debugDescription)")
    }
    
    func testSettings2GPS(){
        XCUIDevice.sharedDevice().orientation = .Portrait
        
        let app = XCUIApplication()
        app.navigationBars["Main"].buttons["Menu 100"].tap()
        app.buttons[" SETTINGS"].tap()
        
        let switch2 = app.switches["0"]
        switch2.tap()

        app.buttons["OK"].tap()
      
        
    }
    
    func testMainRefresh(){
        XCUIDevice.sharedDevice().orientation = .Portrait
        
        let app = XCUIApplication()
        
        let postcodeLabel = app.staticTexts.elementMatchingType(.Any, identifier: "postcodeLabel").label

        app.navigationBars["Main"].buttons["Refresh"].tap()
        
        let postcodeLabel2 = app.staticTexts.elementMatchingType(.Any, identifier: "postcodeLabel").label
        
        XCTAssertEqual(postcodeLabel, postcodeLabel2, "found instead: \(postcodeLabel2.debugDescription)")

    }
    
}
