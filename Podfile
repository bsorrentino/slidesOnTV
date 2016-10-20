# Podfile
#platform :ios, '9.0'
platform :tvos, '9.0'
use_frameworks!
xcodeproj 'slides.xcodeproj'

target 'slides' do
    #pod 'OHPDFImage'
    pod 'RxSwift',    '2.6.0'
    pod 'RxCocoa',    '2.6.0'
    #pod 'RxSwiftExt', '~> 1.2'
    pod 'RxSwiftExt', :git => 'https://github.com/RxSwiftCommunity/RxSwiftExt', :tag => '1.2'
    pod 'SnapKit',    '0.22.0'
    pod 'SettingsKit', :git => 'https://github.com/bsorrentino/SettingsKit.git', :branch => 'develop'
    #pod 'VAProgressCircle'
    #pod 'UAProgressView'
end

target 'slidesTests' do
    #pod 'OHPDFImage'
    pod 'RxSwift',    '2.6.0'
    pod 'RxCocoa',    '2.6.0'
    pod 'RxBlocking', '2.6.0'
    pod 'RxTests',    '2.6.0'
    #pod 'RxSwiftExt', '1.2'
    pod 'RxSwiftExt', :git => 'https://github.com/RxSwiftCommunity/RxSwiftExt', :tag => '1.2'
end

target 'slidesUITests' do
    #pod 'OHPDFImage'
    pod 'RxSwift',    '2.6.0'
    pod 'RxCocoa',    '2.6.0'
    pod 'RxBlocking', '2.6.0'
    pod 'RxTests',    '2.6.0'
    pod 'SnapKit',    '0.22.0'
    #pod 'VAProgressCircle'
    #pod 'UAProgressView'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            #config.build_settings['BASE_SDK'] = 'tvOS 10.0'
            
            config.build_settings['ENABLE_BITCODE'] = 'YES'
            
            cflags = config.build_settings['OTHER_CFLAGS'] || ['$(inherited)']
            cflags << '-fembed-bitcode'
            config.build_settings['OTHER_CFLAGS'] = cflags
        end
    end
end
