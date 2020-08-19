//
//  AssitantViewControllerViewModel.swift
//  Pods
//
//  Created by Vishal on 18/08/20.
//

import Foundation
import googleapis
import AVFoundation

/// This  is an internal protocol to notigfy event changes from the viewController to the parent.
///
protocol AssistantViewControllerViewModelDelegate: class {
	
	/// This method is called when the state changes.
	///
	/// - Parameters:
	///   - state: The `State` object that specifies the current state.
	///
	func updateUIForState(_ state:State)
	
	/// This method is called when the transcript changes.
	///
	/// - Parameters:
	///   - transcript: The `String` of the updated transcript.
	///
	func updateUIForTranscript(_ transcript:String?)
	
	/// This method is called when the language is updated.
	///
	/// - Parameters:
	///   - language: The `LanguageModel` of the updated language.
	///
	func updateLangugage(_ language:LanguageModel)
}

class AssistantViewControllerViewModel {
	
	/// Specifies the current state of the assistant
	///
	var state:State? {
		didSet {
			guard let state = state else {return}
			if oldValue == state {
				return
			}
			viewControllerDelegate?.updateUIForState(state)
			switch state {
			case .STARTED :
				let deadlineTime = DispatchTime.now() +
					.milliseconds(maxTimeForSessionInMillis)
				maxEndingTask?.cancel()
				maxEndingTask = DispatchWorkItem {
					self.finished = true
				}
				DispatchQueue.main.asyncAfter(deadline: deadlineTime,
																			execute: maxEndingTask!)
				resetAudioData()
				startAudio()
				break
			case .ENDED :
				currentTranscript = nil
				resetAudioData()
				stopAudio()
				endingTask?.cancel()
				maxEndingTask?.cancel()
			}
		}
	}
	
	/// Specifies the task associated to the block that needs to be executed once the timeout threshold between 2 consective speech translations is reached.
	///
	var endingTask:DispatchWorkItem?
	
	/// Specifies the task associated to the block that needs to be executed once the maximum time is reached for the speech translation to begin.
	///
	var maxEndingTask:DispatchWorkItem?
	
	/// This variable is used for buffering the audio data until the threshold is met and once met, it will upload the data and clear it.
	///
	var processAudioData: NSMutableData!
	
	/// The variable that contains the audio data of the current speech session [from state STARTED to ENDED]
	///
	var savedAudioData: NSMutableData!
	
	/// The intermidiate audio data that is being appended to reach a threshold and then upload it for transcriptions.
	///
	var audioMetadata = [String:String]()
	
	/// The delegate that will be called upon events. [To the Assistant manager]
	///
	weak var delegate:AssistantViewModelDelegate?
	
	/// The delegate that will be called upon events. [To the hosting viewController class]
	///
	weak var viewControllerDelegate:AssistantViewControllerViewModelDelegate?
	
	/// The `OSStatus`value that describes that status of audio recoder's prepare method.
	///
	var prepareStatus:OSStatus?
	
	/// The `OSStatus`value that describes that status of audio recoder's start method.
	///
	var startStatus:OSStatus?
	
	/// Specifies the current transcript string
	///
	var currentTranscript:String? {
		didSet {
			viewControllerDelegate?.updateUIForTranscript(currentTranscript)
		}
	}
	
	/// Specifies whether current speech - transcript session has ended successfully or not.
	///
	var finished:Bool? = nil {
		didSet {
			guard let finished = finished else {return}
			if(finished) {
				if(currentTranscript != nil) {
					delegate?.dataAndTranscriptCallback(
						savedAudioData,
						audioMetadata: audioMetadata,
						transcript: currentTranscript!)
				}
			}
			state = .ENDED
		}
	}
	
	/// Specifies whether current `LanguageModel`
	///
	var currentLanguage = english {
		didSet {
			delegate?.languageChangeCallback(currentLanguage)
			viewControllerDelegate?.updateLangugage(currentLanguage)
			SpeechRecognitionService.sharedInstance.languageCode
				= currentLanguage.code
		}
	}
	
	init() {
		AudioController.sharedInstance.delegate = self
		audioMetadata["encoding"] = "Signed 16-bit PCM"
		audioMetadata["channels"] = "1"
		audioMetadata["byteOrder"] = "Little-endian"
		audioMetadata["sampleRate"] = String(sampleRate)
	}
	
	/// Method that handles recording start
	///
	func startRecording() {
		state = .STARTED
	}
	
	///Method that handles recording cancel
	///
	func cancelRecording() {
		finished = false
	}
	
	/// Internal method that clears the audio data objects.
	///
	private func resetAudioData() {
		savedAudioData = NSMutableData()
		processAudioData = NSMutableData()
	}
	
	/// Internal method that stops processing and recording of audio.
	///
	private func stopAudio() {
		print("Audio Stopped");
		AudioController.sharedInstance.stop()
		SpeechRecognitionService.sharedInstance.stopStreaming()
	}
	
	/// Internal method that starts processing and recording of audio.
	///
	private func startAudio() {
		print("Audio Started");
		let audioSession = AVAudioSession.sharedInstance()
		do {
			try audioSession.setCategory(AVAudioSession.Category.record)
		} catch {
			print("Error setting AudioSession")
		}
		prepareStatus = AudioController.sharedInstance.prepare(specifiedSampleRate: sampleRate)
		SpeechRecognitionService.sharedInstance.sampleRate = sampleRate
		startStatus = AudioController.sharedInstance.start()
		finished = nil
	}
	
	func languageChanged(_ language:LanguageModel) {
		self.currentLanguage = language
		self.state = .STARTED
	}
}

extension AssistantViewControllerViewModel: AudioControllerDelegate {
	
	/// This method is called once the data is obtained from the audio controller to pass is on to the speech recogniztion service.
	///
	/// - Parameters:
	///   - data: The `Data` object of the current audio data.
	///
	func processSampleData(_ data: Data) {
		processAudioData.append(data)
		savedAudioData.append(data)
		let chunkSize = Int(0.1 * Double(sampleRate))
		if (processAudioData.length > chunkSize) {
			SpeechRecognitionService.sharedInstance.streamAudioData(
				processAudioData,
				completion:
				{ [weak self] (response, error) in
					guard let strongSelf = self else {
						return
					}
					var resultString = ""
					if let response = response {
						if let result = response.resultsArray[0]
							as? StreamingRecognitionResult {
							let array = result.alternativesArray
							let alternative = array?.object(at: 0)
								as! SpeechRecognitionAlternative
							resultString = alternative.transcript
						}
						strongSelf.processResponseObtained(resultString, error: error)
					}
			})
			self.processAudioData = NSMutableData()
		}
	}
	
	/// The internal method that handles the transcript callbacks.
	///
	/// - Parameters:
	///   - result: The `String` object of the current transcript.
	///   - error: The `Error` object to indicate whether the transcription operation did not suceed.
	///
	func processResponseObtained(_ result:String, error:Error?) {
		if(finished != nil) {
			return
		}
		if error != nil {
			finished = true
			return
		}
		let deadlineTime = DispatchTime.now() +
			.milliseconds(maxTimeBetweenWordsInMillis)
		endingTask?.cancel()
		endingTask = DispatchWorkItem {
			self.finished = true
		}
		DispatchQueue.main.asyncAfter(deadline: deadlineTime,
																	execute: endingTask!)
		currentTranscript = result
	}
}
