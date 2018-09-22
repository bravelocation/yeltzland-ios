source 'https://github.com/cocoapods/specs.git'
use_frameworks!

target 'yeltzland' do
  platform :ios, '9.3'
  
  pod 'Font-Awesome-Swift'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'TwitterKit'
  pod 'TwitterCore'
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
  pod 'SDWebImage'
end

target 'watchkitapp Extension' do
  platform :watchos, '4.0'

  pod 'SDWebImage'
end

target 'yeltzlandTVOS' do
    platform :tvos, '11.2'
    
    pod 'SDWebImage'
end

target 'LatestScoreIntentUI' do
    platform :ios, '12.0'
    
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
