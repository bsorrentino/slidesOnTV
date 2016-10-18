# Podfile
#platform :tvos, '9.0'
platform :ios, '9.0'
use_frameworks!
xcodeproj 'slides.xcodeproj'

target 'slides' do
    pod 'RxSwift',    '~> 2.6.0'
    pod 'RxCocoa',    '~> 2.6.0'
    #pod 'RxSwiftExt', '~> 1.2'
    pod 'RxSwiftExt', :git => 'https://github.com/RxSwiftCommunity/RxSwiftExt', :tag => '1.2'
    pod 'OHPDFImage'
    pod 'SnapKit'
    pod 'SettingsKit', :git => 'https://github.com/bsorrentino/SettingsKit.git', :branch => 'develop'
    #pod 'VAProgressCircle'
    #pod 'UAProgressView'
end

target 'slidesTests' do
    pod 'RxSwift',    '~> 2.6.0'
    pod 'RxCocoa',    '~> 2.6.0'
    pod 'RxBlocking', '~> 2.6.0'
    pod 'RxTests',    '~> 2.6.0'
    #pod 'RxSwiftExt', '~> 1.2'
    pod 'RxSwiftExt', :git => 'https://github.com/RxSwiftCommunity/RxSwiftExt', :tag => '1.2'
    pod 'OHPDFImage'
end

target 'slidesUITests' do
    pod 'RxSwift',    '~> 2.6.0'
    pod 'RxCocoa',    '~> 2.6.0'
    pod 'RxBlocking', '~> 2.6.0'
    pod 'RxTests',    '~> 2.6.0'
    pod 'OHPDFImage'
    pod 'SnapKit'
    #pod 'VAProgressCircle'
    #pod 'UAProgressView'
end
