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
		let assitantViewControllerViewModel = AssistantViewControllerViewModel()
		assitantViewControllerViewModel.startRecording()
		XCTAssertEqual(assitantViewControllerViewModel.prepareStatus,
									 OSStatus(0),
									 "The state should be started")
		XCTAssertEqual(assitantViewControllerViewModel.startStatus,
									 OSStatus(0),
									 "The state should be started")
		XCTAssertEqual(assitantViewControllerViewModel.state,
									 .STARTED,
									 "The state should be started")
		assitantViewControllerViewModel.processResponseObtained("This is", error: nil)
		assitantViewControllerViewModel.processResponseObtained("This is a test", error: nil)
		XCTAssertEqual(assitantViewControllerViewModel.currentTranscript,
									 "This is a test",
									 "The transcript should match")
		let exp = expectation(description:"waiting for timeOut")
		DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
			exp.fulfill()
		}
		waitForExpectations(timeout: 4.0) { (error) in
			XCTAssertEqual(assitantViewControllerViewModel.state,
										 .ENDED,
										 "The state should be ended")
			XCTAssertEqual(assitantViewControllerViewModel.currentTranscript,
										 nil,
										 "The transcript should be nil")
		}
		
	}
	
	func testLanguageChange() {
		// This is an example of a functional test case.
		// Use XCTAssert and related functions to verify your tests produce the correct results.
		let assitantViewControllerViewModel = AssistantViewControllerViewModel()
		XCTAssertEqual(assitantViewControllerViewModel.currentLanguage,
									 english,
									 "The language should be english as default")
		assitantViewControllerViewModel.startRecording()
		XCTAssertEqual(assitantViewControllerViewModel.prepareStatus,
									 OSStatus(0),
									 "The state should be started")
		XCTAssertEqual(assitantViewControllerViewModel.startStatus,
									 OSStatus(0),
									 "The state should be started")
		assitantViewControllerViewModel.languageChanged(tamil)
		XCTAssertEqual(assitantViewControllerViewModel.state,
									 .STARTED,
									 "The state should be started")
		XCTAssertEqual(assitantViewControllerViewModel.currentLanguage,
									 tamil,
									 "The languages should match")
		assitantViewControllerViewModel.processResponseObtained("நான் தமிழ்", error: nil)
		assitantViewControllerViewModel.processResponseObtained("நான் தமிழ் பேசுகிறேன்", error: nil)
		XCTAssertEqual(assitantViewControllerViewModel.currentTranscript,
									 "நான் தமிழ் பேசுகிறேன்",
									 "The transcript should match")
		let exp = expectation(description:"waiting for timeOut")
		DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
			exp.fulfill()
		}
		waitForExpectations(timeout: 4.0) { (error) in
			XCTAssertEqual(assitantViewControllerViewModel.state,
										 .ENDED,
										 "The state should be ended")
			XCTAssertEqual(assitantViewControllerViewModel.currentTranscript,
										 nil,
										 "The transcript should be nil")
		}
		
	}
	
	func testCancelCase() {
		// This is an example of a functional test case.
		// Use XCTAssert and related functions to verify your tests produce the correct results.
		let assitantViewControllerViewModel = AssistantViewControllerViewModel()
		assitantViewControllerViewModel.startRecording()
		XCTAssertEqual(assitantViewControllerViewModel.prepareStatus,
									 OSStatus(0),
									 "The state should be started")
		XCTAssertEqual(assitantViewControllerViewModel.startStatus,
									 OSStatus(0),
									 "The state should be started")
		XCTAssertEqual(assitantViewControllerViewModel.state,
									 .STARTED,
									 "The state should be started")
		assitantViewControllerViewModel.processResponseObtained("This is", error: nil)
		assitantViewControllerViewModel.processResponseObtained("This is a test", error: nil)
		assitantViewControllerViewModel.cancelRecording()
		XCTAssertEqual(assitantViewControllerViewModel.state,
									 .ENDED,
									 "The state should be ended")
		XCTAssertEqual(assitantViewControllerViewModel.currentTranscript,
									 nil,
									 "The transcript should be nil")
	}
	
	func testMultipleStartCase() {
		// This is an example of a functional test case.
		// Use XCTAssert and related functions to verify your tests produce the correct results.
		let assitantViewControllerViewModel = AssistantViewControllerViewModel()
		assitantViewControllerViewModel.startRecording()
		assitantViewControllerViewModel.startRecording()
		XCTAssertEqual(assitantViewControllerViewModel.prepareStatus,
									 OSStatus(0),
									 "The state should be started")
		XCTAssertEqual(assitantViewControllerViewModel.startStatus,
									 OSStatus(0),
									 "The state should be started")
		XCTAssertEqual(assitantViewControllerViewModel.state,
									 .STARTED,
									 "The state should be started")
		assitantViewControllerViewModel.processResponseObtained("This is", error: nil)
		assitantViewControllerViewModel.processResponseObtained("This is a test", error: nil)
		assitantViewControllerViewModel.cancelRecording()
		XCTAssertEqual(assitantViewControllerViewModel.state,
									 .ENDED,
									 "The state should be ended")
		XCTAssertEqual(assitantViewControllerViewModel.currentTranscript,
									 nil,
									 "The transcript should be nil")
	}
	
}
