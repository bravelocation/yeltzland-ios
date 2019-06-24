//
//  yeltzlandUITests.swift
//  yeltzlandUITests
//
//  Created by John Pollard on 05/05/2016.
//  Copyright © 2016 John Pollard. All rights reserved.
//

import XCTest

class yeltzlandUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testYeltzForum() {
        XCUIApplication().tabBars.buttons["Yeltz Forum"].tap()
        self.waitForWebPageLoad()
        snapshot("01Forum")
    }
    
    func testOfficialSite() {
        XCUIApplication().tabBars.buttons["Official Site"].tap()
        self.waitForWebPageLoad()
        snapshot("02Site")
    }
    
    func testYeltzTV() {
        XCUIApplication().tabBars.buttons["Yeltz TV"].tap()
        self.waitForWebPageLoad()
        snapshot("03TV")
    }
    
    func testTwitter() {
        XCUIApplication().tabBars.buttons["Twitter"].tap()
        self.waitForWebPageLoad()
        snapshot("04Twitter")
    }
    
    func testMore() {
        XCUIApplication().tabBars.buttons["More"].tap()
        snapshot("05More")
    }
    
    func waitForWebPageLoad() {
        let delayExpectation = expectation(description: "Waiting for page load")
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            delayExpectation.fulfill()
        }
        wait(for: [delayExpectation], timeout: 5.0, enforceOrder: true)
    }
}
