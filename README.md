# speechAssistant

[![CI Status](https://img.shields.io/travis/vishaladori/speechAssistant.svg?style=flat)](https://travis-ci.org/vishaladori/speechAssistant)
[![Version](https://img.shields.io/cocoapods/v/speechAssistant.svg?style=flat)](https://cocoapods.org/pods/speechAssistant)
[![License](https://img.shields.io/cocoapods/l/speechAssistant.svg?style=flat)](https://cocoapods.org/pods/speechAssistant)
[![Platform](https://img.shields.io/cocoapods/p/speechAssistant.svg?style=flat)](https://cocoapods.org/pods/speechAssistant)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

speechAssistant is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'speechAssistant' :git => 'https://github.com/vishal-i4gs/speechAssistant'
```

## Usage

- Call setup on the rootviewController/initial viewController :
```
Assistant.shared.setup(languages: [english, tamil, hindi], delegate: self)
```

- Call configure assitant on the viewController that is currently active :
```
Assistant.shared.configureAssistant(viewController)
```

- Implement `AssistantDelegate` in order to get callbacks from the assistant :
```
func obtainedSpeechCallback(_ speech: String) {
	print("The spoken text is ",speech)
	let resultViewController = ResultViewController()
	resultViewController.resultString = speech
	self.pushViewController(resultViewController, animated: true)
}
```

## Author

vishal, vishal.i4gs@gmail.com

## License

speechAssistant is available under the MIT license. See the LICENSE file for more info.
