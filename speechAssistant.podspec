#
# Be sure to run `pod lib lint speechAssistant.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
	s.name             = 'speechAssistant'
	s.version          = '0.1.0'
	s.summary          = 'A short description of speechAssistant.'
	s.description      = 'This is the speech assistant SDK'
	s.homepage         = 'https://github.com/vishal-i4gs/speechAssistant'
	s.license          = { :type => 'MIT', :file => 'LICENSE' }
	s.author           = { 'vishal-i4gs' => 'vishal.i4gs@gmail.com' }
	s.source           = { :git => 'https://github.com/vishal-i4gs/speechAssistant.git', :tag => s.version.to_s }
	s.ios.deployment_target = '9.2'
	s.source_files = 'speechAssistant/Classes/**/*'
	s.resources = "speechAssistant/Assets/*.{xib}"
	s.dependency 'googleapis'
	s.pod_target_xcconfig = {
		'GCC_PREPROCESSOR_DEFINITIONS' => '$(inherited) GPB_GRPC_FORWARD_DECLARE_MESSAGE_PROTO=1',
	}
end
