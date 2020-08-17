//
//  Language.swift
//  speechAssistant
//
//  Created by Vishal on 01/08/20.
//

import Foundation

/// The `LanguageModel` is the model associated with a langugage.g
///
public struct LanguageModel:Equatable {
	
	let name : String
	let code : String
	let caption : String
	
	/// The comparator operator to compare whether two `LanguageModel` objects are the same or not.
	///
	public static func ==(lhs: LanguageModel,
												rhs: LanguageModel) -> Bool {
		return lhs.code == rhs.code
	}
	
}
