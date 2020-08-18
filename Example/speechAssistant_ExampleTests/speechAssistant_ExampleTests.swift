//
//  speechAssistant_ExampleTests.swift
//  speechAssistant_ExampleTests
//
//  Created by Vishal on 12/08/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import speechAssistant


class speechAssistant_ExampleTests: XCTestCase {
	
	override func setUp() {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}
	
	func testDefaultCase() {
		// This is an example of a functional test case.
		// Use XCTAssert and related functions to verify your tests produce the correct results.
	  let assitantViewController = AssistantViewController()
		assitantViewController.performUIOperations = false
		assitantViewController.recordAudio(NSObject())
		XCTAssertEqual(assitantViewController.state,
									 .STARTED,
									 "The state should be started")
		assitantViewController.processResponseObtained("This is", error: nil)
		assitantViewController.processResponseObtained("This is a test", error: nil)
		let exp = expectation(description:"waiting for timeOut")
		DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
			exp.fulfill()
		}
		waitForExpectations(timeout: 4.0) { (error) in
			XCTAssertEqual(assitantViewController.state,
										 .ENDED,
										 "The state should be ended")
			XCTAssertEqual(assitantViewController.currentTranscript,
										 "This is a test",
										 "The transcript should match")
		}

	}
	
	func testLanguageChange() {
		// This is an example of a functional test case.
		// Use XCTAssert and related functions to verify your tests produce the correct results.
	  let assitantViewController = AssistantViewController()
		assitantViewController.performUIOperations = false
		XCTAssertEqual(assitantViewController.currentLanguage,
									 english,
									 "The language should be english as default")
		assitantViewController.recordAudio(NSObject())
		assitantViewController.languageChanged(tamil)
		XCTAssertEqual(assitantViewController.currentLanguage,
									 tamil,
									 "The language should be changed")
		XCTAssertEqual(assitantViewController.state,
									 .STARTED,
									 "The state should be started")
		XCTAssertEqual(assitantViewController.currentLanguage,
									 tamil,
									 "The languages should match")
		assitantViewController.processResponseObtained("நான் தமிழ்", error: nil)
		assitantViewController.processResponseObtained("நான் தமிழ் பேசுகிறேன்", error: nil)
		let exp = expectation(description:"waiting for timeOut")
		DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
			exp.fulfill()
		}
		waitForExpectations(timeout: 4.0) { (error) in
			XCTAssertEqual(assitantViewController.state,
										 .ENDED,
										 "The state should be ended")
			XCTAssertEqual(assitantViewController.currentTranscript,
										 "நான் தமிழ் பேசுகிறேன்",
										 "The transcript should match")
		}

	}
	
	func testPerformanceExample() {
		// This is an example of a performance test case.
		measure {
			// Put the code you want to measure the time of here.
		}
	}
	
}
