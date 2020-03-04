source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!
inhibit_all_warnings!

target 'yeltzland' do
  platform :ios, '11.0'
  
  pod 'TwitterKit', :podspec => 'https://raw.githubusercontent.com/bravelocation/twitter-kit-ios/master/TwitterKit/TwitterKit.podspec'
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'SDWebImage'
  
  pod 'SwiftLint'
end

target 'watchkitapp Extension' do
  platform :watchos, '6.0'

  pod 'SDWebImage'
end

target 'yeltzlandTVOS' do
    platform :tvos, '11.2'
    
    pod 'SDWebImage'
end

target 'LatestScoreIntentUI' do
    platform :ios, '11.0'
    
    pod 'SDWebImage'
end


post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        if config.name == 'Release'
            config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
        else
            config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
        end
    end
end
