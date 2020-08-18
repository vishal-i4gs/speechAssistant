//
//  AssistantViewController.swift
//  speechAssistant
//
//  Created by Vishal on 31/07/20.
//

import Foundation
import googleapis
import AVFoundation

/// This  is an internal protocol to notigfy event changes from the viewController to the parent.
///
protocol AssistantViewControllerDelegate: class {
	
	/// This method is called when the transcript is obtained and the data needs to be uploaded to the server.
	///
	/// - Parameters:
	///   - data: The `NSMutableData` object that needs to be uploaded to the server.
	///   - audioMetadata: The metadata of the audio.
	///   - transcript : The `String` transcript of the audio.
	///
	func dataAndTranscriptCallback(_ data:NSMutableData,
																 audioMetadata:[String:String],
																 transcript: String)
	
	/// This method is called when the user changes the current language.
	///
	/// - Parameters:
	///   - language: The `LanguageModel` of the updated language.
	///
	func languageChangeCallback(_ language:LanguageModel)
}

/// The `AssistantViewController` is the view controller that is responsible for the assistant UI and its functionailities.
///
///	An instance of this class needs to be created and added as a `subview` and attached as a `childViewController`.
///
class AssistantViewController : UIViewController {
	
	@IBOutlet weak var micImageView: UIImageView!
	@IBOutlet weak var bottomView: UIView!
	@IBOutlet weak var contentView: UIView!
	@IBOutlet weak var contentLabel: UILabel!
	@IBOutlet weak var languageButton: UIButton!
	@IBOutlet weak var wavesView: WavesLayer!
	
	/// An enum value which respresents the current state.
	///
	enum State {
		case STARTED
		case ENDED
	}
	
	/// Specifies the current state of the assistant
	///
	var state:State = .ENDED {
		didSet {
			performUIChanges()
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
	
	/// The variable that contains the intermidate audio data that is uploaded to google cloud speech for transcriptions.
	/// This variable is used for buffering the audio data until the threshold is met and once met, it will upload the data and clear it.
	///
	var processAudioData: NSMutableData!
	
	/// The variable that contains the audio data of the current speech session [from state STARTED to ENDED]
	///
	var savedAudioData: NSMutableData!
	
	/// The intermidiate audio data that is being appended to reach a threshold and then upload it for transcriptions.
	///
	var audioMetadata = [String:String]()
	
	
	/// The delegate that will be called upon events.
	///
	weak var delegate:AssistantViewControllerDelegate?
	
	/// The current array of all supported `LanguageModel`
	///
	var supportedLanguages = [LanguageModel]()
	
	/// Specifies the current transcript string
	///
	var currentTranscript:String? {
		didSet {
			if(performUIOperations == false) {
				return
			}
			if(currentTranscript == nil) {
				contentLabel.text = currentLanguage.caption
				return
			}
			contentLabel.text = "\"\(String(describing: currentTranscript!))\""
		}
	}
	
	var performUIOperations:Bool?
	
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
			currentTranscript = nil
			SpeechRecognitionService.sharedInstance.languageCode
				= currentLanguage.code
			if(performUIOperations == false) {
				return
			}
			languageButton.setTitle(currentLanguage.name, for: .normal)
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		AudioController.sharedInstance.delegate = self
		currentTranscript = nil
		micImageView.isUserInteractionEnabled = true
		micImageView.addGestureRecognizer(UITapGestureRecognizer(
			target: self, action: #selector(self.recordAudio(_:))))
		audioMetadata["encoding"] = "Signed 16-bit PCM"
		audioMetadata["channels"] = "1"
		audioMetadata["byteOrder"] = "Little-endian"
		audioMetadata["sampleRate"] = String(sampleRate)
	}
	
	/// Method that handles the record button click
	///
	@objc func recordAudio(_ sender: NSObject) {
		state = .STARTED
	}
	
	/// Method that handles the cancel button click
	///
	@IBAction func cancelButtonPressed(_ sender: UIButton) {
		finished = false
	}
	
	/// Method that handles the language button click
	///
	@IBAction func languageButtonPressed(_ sender: UIButton) {
		if(supportedLanguages.count == 1) {
			return
		}
		state = .ENDED
		let languageSelectionOption = UIAlertController(
			title: "Select Language",
			message: "", preferredStyle: UIAlertController.Style.actionSheet)
		
		for language in supportedLanguages {
			let action = UIAlertAction(title: language.name, style: .default) {
				(action: UIAlertAction) in
				self.languageChanged(language)
			}
			languageSelectionOption.addAction(action)
		}
		
		let cancelAction = UIAlertAction(title: "Cancel",
																		 style: .cancel,
																		 handler: nil)
		
		languageSelectionOption.addAction(cancelAction)
		self.present(languageSelectionOption, animated: true, completion: nil)
	}
	
	/// Internal method that takes the current state makes the required UI changes based on it.
	///
	private func performUIChanges() {
		if(performUIOperations == false) {
			return
		}
		switch state {
		case .STARTED:
			wavesView.isHidden = false
			wavesView.startDisplayLink()
			micImageView.isUserInteractionEnabled = false
			UIView.animate(withDuration: 0.35) {
				self.bottomView.isHidden = false
				self.contentView.isHidden = false
				self.micImageView.tintColor = UIColor.systemRed
			}
			break
		case .ENDED:
			wavesView.isHidden = true
			wavesView.stopDisplayLink()
			self.contentView.isHidden = true
			self.micImageView.tintColor = UIColor.systemGray
			self.currentTranscript = nil
			self.bottomView.isHidden = true
			micImageView.isUserInteractionEnabled = true
			break
		}
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
		_ = AudioController.sharedInstance.prepare(specifiedSampleRate: sampleRate)
		SpeechRecognitionService.sharedInstance.sampleRate = sampleRate
		_ = AudioController.sharedInstance.start()
		finished = nil
	}
	
	func languageChanged(_ language:LanguageModel) {
		self.currentLanguage = language
		self.state = .STARTED
	}
}

extension AssistantViewController: AudioControllerDelegate {
	
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
							strongSelf.currentTranscript = alternative.transcript
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
