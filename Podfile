platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

target 'NimbleSurvey' do
  # UI
  pod 'SnapKit'

  # Tools
  pod 'R.swift'

  # Development
  pod 'SwiftLint'

  target 'NimbleSurveyTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end

