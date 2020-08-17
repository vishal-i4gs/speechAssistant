//
//  RequestManager.swift
//  speechAssistant
//
//  Created by Vishal on 01/08/20.
//

import Foundation

/// The `RequestManager` is a class which handles request session and headers for all the API requests being made.
///
open class RequestManager {
	
	/// The default configuration of the current URLSession.
	///
	private let configuration = URLSessionConfiguration.default

	/// The current URLSession that variable.
	///
	private var session:URLSession?
		
	/// The internal method that gives access to the current URLSession.
	///
	///	This method creates an URLSession when its not created and once it is created it returns the previously created instance.
	///
	/// - returns: `URLSession` the current URLSession.
	///
	func getSession() -> URLSession {
		if(session == nil) {
			if #available(iOS 11.0, *) {
				configuration.waitsForConnectivity = true
			}
			session = URLSession(configuration: configuration)
		}
		return session!
	}
	
}
