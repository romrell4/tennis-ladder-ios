# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'
inhibit_all_warnings!

target 'TennisLadder' do
	# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
	use_frameworks!
	
	# Pods for TennisLadder
	pod 'Alamofire', '~>4.9.1'
	pod 'moa', '~>12.0.0'
	pod 'Firebase/Core', '~>6.14.0'
	pod 'FirebaseUI/Auth', '~>8.4.0'
	pod 'FirebaseUI/Email', '~>8.4.0'
    pod 'FirebaseUI/OAuth', '~>8.4.0'
	pod 'FirebaseUI/Google', '~>8.4.0'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
