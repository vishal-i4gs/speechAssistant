//
//  Constants.swift
//  speechAssistant
//
//  Created by Vishal on 01/08/20.
//

import Foundation

let sampleRate = 16000
let maxTimeBetweenWordsInMillis = 2000
let maxTimeForSessionInMillis = 15000
let audioUploadBaseUrl = "https://storage.googleapis.com/upload/storage/v1/b/sample-audios-vos/o?uploadType=media&name=sounds/"
let audioGetReqBaseUrl = "https://storage.googleapis.com/sample-audios-vos/sounds/"
let metaDataPostUrl = "https://sampleaction-3ebda.firebaseio.com/sounds.json"

public let tamil = LanguageModel(name: "தமிழ்",code: "ta-IN",caption: "தயவுகூர்ந்து ஏதாவது சொல்")
public let english = LanguageModel(name: "English",code: "en-IN",caption: "Please say something")
public let hindi = LanguageModel(name: "हिन्दी",code: "hi-IN",caption: "कृपया कुछ कहे")

/// An enum value which respresents the current state.
///
enum State {
	case STARTED
	case ENDED
}

