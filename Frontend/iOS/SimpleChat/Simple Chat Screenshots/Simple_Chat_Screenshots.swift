//
//  Simple_Chat_Screenshots.swift
//  Simple Chat Screenshots
//
//  Created by Maxim Pervushin on 18/03/16.
//  Copyright © 2016 Maxim Pervushin. All rights reserved.
//

import XCTest

class Simple_Chat_Screenshots: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testExample() {
        
        let app = XCUIApplication()
        
        snapshot("01ChatsListScreen")
        
        app.tables.cells.staticTexts["Local:3000"].tap()

        snapshot("02ChatScreen")
        
        let local3000NavigationBar = app.navigationBars["Local:3000"]
        local3000NavigationBar.buttons["Authentication"].tap()

        snapshot("02LogInScreen")

        app.buttons["Sign Up"].tap()

        snapshot("02SignUpScreen")

        let closeButton = app.buttons["Close"]
        closeButton.tap()
        closeButton.tap()
        local3000NavigationBar.buttons["Chats"].tap()
        
    }
    
}
