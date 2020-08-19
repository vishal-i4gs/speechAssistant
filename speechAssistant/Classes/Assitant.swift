//
//  Assitant.swift
//  speechAssistant
//
//  Created by Vishal on 31/07/20.
//

import Foundation

extension Float {
	
	/// A helper extension function to convert bytes into kilobytes.
	///
	/// - returns: The `Float` representation of the current bytes in kiloBytes.
	///
	func BtoKb() -> Float {
		return self/1024
	}
}

/// This protocol contains helpful methods to alert you of specific events. If you want to be notified about those
/// events, you will have to set a delegate to your `AssistantDelegate` instance.
public protocol AssistantDelegate: class {
	
	/// This method is called when the current speech is processed and the output of the speech is obtained.
	///
	/// - Parameters:
	///   - speech: The `String` transcript of the speech that was last spoken.
	///
	func obtainedSpeechCallback(_ speech: String)
}


/// This  is an internal protocol to notigfy event changes from the viewController to the parent.
///
protocol AssistantViewModelDelegate: class {
	
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


/// The `Assistant` is a only user facing instance that is used to setup and provides a delegate to handle callbacks appropriately.
///
public class Assistant {
	
	/// The shared instance object to the Assistant. It is recommended to use the shared.
	///
	public static let shared = Assistant()
	
	/// The shared instance object to the Requests class. It contains methods to all the types of API calls that can be made to the service.
	///
	let requests = Requests()
	
	/// The reference to the current assistant view controller that is attached on top of the current topviewcontroller.
	///
	var assistantViewController: AssistantViewController?
	
	/// The reference to the current assistant view controller that is attached on top of the current topviewcontroller.
	///
	var assistantViewControllerViewModel: AssistantViewControllerViewModel?
	
	/// The delegate object that is used to return all the callbacks from the assistant.
	///
	weak var delegate: AssistantDelegate?
	
	/// The array of `LanguageModel` that needs to be supported by the assistant.
	///
	var supportedLanguages:[LanguageModel]?
	
	/// Reference to the current `LanguageModel` that is selected by the user.
	///
	var currentLanguage:LanguageModel?
	
	/// The public method that is responsible for setting up the assitant.
	///
	/// - Parameters:
	///   - languages: The array of `LanguageModel` that needs to be supported by the assitant.
	///   - delegate: The `AssistantDelegate` object which is used to send events/callbacks back to the hosting app.
	///
	public func setup(languages :[LanguageModel]?, delegate: AssistantDelegate?) {
		self.delegate = delegate
		supportedLanguages = [english, tamil]
		if(languages != nil && languages!.count > 0) {
			supportedLanguages = languages!
		}
		currentLanguage = supportedLanguages![0]
		assistantViewController =  AssistantViewController(
			nibName: "AssitantViewController", bundle: Bundle(
				for: AssistantViewController.self))
		assistantViewControllerViewModel = AssistantViewControllerViewModel()
		assistantViewController?.assistantViewModel = assistantViewControllerViewModel
		assistantViewControllerViewModel?.viewControllerDelegate = assistantViewController
		assistantViewControllerViewModel?.delegate = self
	}
	
	/// The public method that is responsible for setting up the assitant view controller for the current top view controller.
	///
	/// - Parameters:
	///		- parent : The current view controller that is visible on the screen.
	///
	public func configureAssistant(_ parent: UIViewController) {
		if (!parent.children.contains(self.assistantViewController!)) {
			parent.addChild(self.assistantViewController!)
			self.assistantViewController!.didMove(toParent: parent)
		}
		let theHeight = parent.view.frame.size.height
		self.assistantViewController!.view.frame = CGRect(
			x: 0, y:theHeight-300, width: parent.view.frame.width, height: 300)
		if (!parent.view.subviews
			.contains(self.assistantViewController!.view)) {
			assistantViewController!.view.backgroundColor = UIColor.clear
			parent.view.addSubview((self.assistantViewController!.view))
		}
		self.assistantViewController?.supportedLanguages = supportedLanguages!
		self.assistantViewControllerViewModel?.currentLanguage = currentLanguage!
		self.assistantViewControllerViewModel?.state = .ENDED
	}
}

extension Assistant: AssistantViewModelDelegate {
	
	/// This method is called when the user changes the current language.
	///
	/// - Parameters:
	///   - language: The `LanguageModel` of the updated language.
	///
	func languageChangeCallback(_ language: LanguageModel) {
		self.currentLanguage = language
	}
	
	/// This method is called when the transcript is obtained and the data needs to be uploaded to the server.
	///
	/// - Parameters:
	///   - data: The `NSMutableData` object that needs to be uploaded to the server.
	///   - audioMetadata: The metadata of the audio.
	///   - transcript : The `String` transcript of the audio.
	///
	func dataAndTranscriptCallback(
		_ data: NSMutableData,
		audioMetadata: [String : String],
		transcript: String) {
		delegate?.obtainedSpeechCallback(transcript)
		var uploadMetaData = [String:String]()
		uploadMetaData.merge(dict: audioMetadata)
		uploadMetaData["transcript"] = transcript
		requests.uploadDataToGoogleCloud(data, metaData: uploadMetaData) {
			[weak self](bytes, fileName, url, success, error) in
			guard let strongSelf = self else {return}
			if(!success) {
				print("Error with "+(error?.localizedDescription ?? "Unknown Error"))
				return
			}
			var message = "File size is "+String(format: "%.1f", bytes)+" KB"
			message = message + "\n File name is "+fileName
			message = message + "\n File Url is "+url
			strongSelf.showAlertController(message)
		}
	}
	
	/// An internal method to show an alert view once the upload is successful.
	///
	/// - Parameters:
	///   - message: The message that needs to be displayed in the alert.
	///
	private func showAlertController(_ message:String) {
		let alert = UIAlertController(
			title: "File Uploaded",
			message: message,
			preferredStyle: UIAlertController.Style.alert)
		alert.addAction(UIAlertAction(
			title: "Okay",
			style: UIAlertAction.Style.default, handler: nil))
		assistantViewController?.present(
			alert,
			animated: true, completion: nil)
	}
	
}
