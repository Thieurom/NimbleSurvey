platform :ios, '10.0'
use_frameworks!
inhibit_all_warnings!

target 'NimbleSurvey' do
  # UI
  pod 'SnapKit'
  pod 'RxDataSources', '~> 5.0'
  pod 'Kingfisher'
  pod 'SkeletonView'
  pod "FlexiblePageControl"
  pod 'Toast-Swift', '~> 5.0.1'
  
  # Network
  pod 'Alamofire'
  pod 'RxAlamofire'

  # Parsing
  pod 'Poly', :git => 'https://github.com/mattpolzin/Poly.git'
  pod 'MP-JSONAPI', :git => 'https://github.com/mattpolzin/JSONAPI.git'

  # Secure storage
  pod 'KeychainAccess'

  # Reactive
  pod 'RxSwift', '6.5.0'
  pod 'RxCocoa', '6.5.0'

  # Tools
  pod 'R.swift'

  # Development
  pod 'SwiftLint'

  target 'NimbleSurveyTests' do
    inherit! :search_paths

    pod 'RxBlocking', '6.5.0'
    pod 'RxTest', '6.5.0'
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end

