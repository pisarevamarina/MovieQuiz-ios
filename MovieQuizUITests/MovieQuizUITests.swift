//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Марина Писарева on 04.01.2023.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()

        app = XCUIApplication()
        app.launch()
           
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()

        app.terminate()
        app = nil
    }
    
    func testYesButton() {
        let firstPoster = app.images["Poster"]
        
        app.buttons["Yes"].tap()
        
        let secondPoster = app.images["Poster"]
        let indexLabel = app.staticTexts["Index"]

        sleep(10)

        XCTAssertTrue(indexLabel.label == "2/10")
        XCTAssertFalse(firstPoster == secondPoster)
    }
    
    func testNoButton() {
        let firstPoster = app.images["Poster"]
        
        app.buttons["No"].tap()
        
        let secondPoster = app.images["Poster"]
        let indexLabel = app.staticTexts["Index"]
        
        sleep(10)
        
        XCTAssertTrue(indexLabel.label == "2/10")
        XCTAssertFalse(firstPoster == secondPoster)
    }
    
    func testGameFinish() {
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        sleep(2)
        
        let alert = app.alerts["Results"]
        
        XCTAssertTrue(app.alerts["Results"].exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "Сыграть еще раз")
    }

    func testAlertDismiss() {
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        sleep(5)
        
        let alert = app.alerts["Results"]
        sleep(5)
        alert.buttons.firstMatch.tap()
        
        sleep(5)
        
        let indexLabel = app.staticTexts["Index"]
        sleep(5)
        XCTAssertFalse(app.alerts["Results"].exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
}
