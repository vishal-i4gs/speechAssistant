//
//  NavigationController.swift
//  speechAssistant_Example
//
//  Created by Vishal on 01/08/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import speechAssistant

class NavigationController: UINavigationController,
UINavigationControllerDelegate {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.delegate = self
		Assistant.shared.setup(languages: [english, tamil, hindi], delegate: self)
	}
	
	// MARK: UINavigationController Delegate
	func navigationController(
		_ navigationController: UINavigationController,
		willShow viewController: UIViewController,
		animated: Bool) {		
		Assistant.shared.configureAssistant(viewController)
	}
	
}

extension NavigationController: AssistantDelegate {
	func obtainedSpeechCallback(_ speech: String) {
		print("The spoken text is ",speech)
		let resultViewController = ResultViewController()
		resultViewController.resultString = speech
		self.pushViewController(resultViewController, animated: true)
	}
}
