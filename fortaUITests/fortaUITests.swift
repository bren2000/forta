//
//  fortaUITests.swift
//  fortaUITests
//
//  Created by brendon mckinley on 3/10/2015.
//  Copyright © 2015 Brendon McKinley. All rights reserved.
//

import XCTest

class fortaUITests: XCTestCase {
        
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
    
    func testExample() {
        
        let app = XCUIApplication()
        let fortaIcon = app.scrollViews.otherElements.icons["forta"]
        fortaIcon.swipeDown()
        fortaIcon.doubleTap()
        fortaIcon.swipeLeft()
        fortaIcon.doubleTap()
        app.childrenMatchingType(.Window).elementBoundByIndex(0).swipeRight()
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
}
