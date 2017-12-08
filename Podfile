source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

target 'yeltzland' do
  pod 'Font-Awesome-Swift'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'TwitterKit'
  pod 'TwitterCore'
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end
