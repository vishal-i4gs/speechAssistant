//
//  AssistantViewController.swift
//  speechAssistant
//
//  Created by Vishal on 31/07/20.
//

import Foundation

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
	
	/// The `AssistantViewControllerViewModel` object of the viewModel responsible for this viewController.
	///
	var assistantViewModel:AssistantViewControllerViewModel?
	
	/// The current array of all supported `LanguageModel`
	///
	var supportedLanguages = [LanguageModel]()
	
	/// Specifies the current transcript string
	///
	var currentTranscript:String? {
		didSet {
			if(currentTranscript == nil) {
				contentLabel.text = currentLanguage.caption
				return
			}
			contentLabel.text = "\"\(String(describing: currentTranscript!))\""
		}
	}
	
	/// Specifies whether current `LanguageModel`
	///
	var currentLanguage = english {
		didSet {
			currentTranscript = nil
			languageButton.setTitle(currentLanguage.name, for: .normal)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		micImageView.isUserInteractionEnabled = true
		micImageView.addGestureRecognizer(UITapGestureRecognizer(
			target: self, action: #selector(self.recordAudio(_:))))
	}
	
	/// Method that handles the record button click
	///
	@objc func recordAudio(_ sender: NSObject) {
		assistantViewModel?.startRecording()
	}
	
	/// Method that handles the cancel button click
	///
	@IBAction func cancelButtonPressed(_ sender: UIButton) {
		assistantViewModel?.cancelRecording()
	}
	
	/// Method that handles the language button click
	///
	@IBAction func languageButtonPressed(_ sender: UIButton) {
		assistantViewModel?.cancelRecording()
		if(supportedLanguages.count == 1) {
			return
		}
		let languageSelectionOption = UIAlertController(
			title: "Select Language",
			message: "", preferredStyle: UIAlertController.Style.actionSheet)
		
		for language in supportedLanguages {
			let action = UIAlertAction(title: language.name, style: .default) {
				(action: UIAlertAction) in
				self.assistantViewModel?.languageChanged(language)
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
	private func performUIChanges(_ state: State) {
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
			self.bottomView.isHidden = true
			micImageView.isUserInteractionEnabled = true
			break
		}
	}
	
}

extension AssistantViewController: AssistantViewControllerViewModelDelegate {
	
	/// This method is called when the language is updated.
	///
	/// - Parameters:
	///   - language: The `LanguageModel` of the updated language.
	///
	func updateLangugage(_ language: LanguageModel) {
		self.currentLanguage = language
	}
	
	/// This method is called when the state changes.
	///
	/// - Parameters:
	///   - state: The `State` object that specifies the current state.
	///
	func updateUIForState(_ state: State) {
		performUIChanges(state)
	}
	
	/// This method is called when the transcript changes.
	///
	/// - Parameters:
	///   - transcript: The `String` of the updated transcript.
	///
	func updateUIForTranscript(_ transcript: String?) {
		currentTranscript = transcript
	}
	
}
