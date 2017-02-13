# Podfile
#platform :ios, '9.0'
platform :tvos, '9.0'
use_frameworks!
project 'slides.xcodeproj'

target 'slides' do
    pod 'RxSwift',    '3.2.0'
    pod 'RxCocoa',    '3.2.0'
    #pod 'RxSwiftExt', :git => 'https://github.com/RxSwiftCommunity/RxSwiftExt', :tag => '1.2'
    pod 'RxSwiftExt', '2.1.0'
    pod 'SnapKit',    '3.1.2'
    pod 'SettingsKit', :git => 'https://github.com/bsorrentino/SettingsKit.git', :branch => 'develop'
end

target 'slidesTests' do
    pod 'RxBlocking', '3.2.0'
    pod 'RxTest',     '3.2.0'
end

target 'slidesUITests' do
    pod 'RxBlocking', '3.2.0'
    pod 'RxTest',     '3.2.0'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            
            config.build_settings['ENABLE_BITCODE'] = 'YES'
            config.build_settings['BITCODE_GENERATION_MODE'] = 'bitcode'
            
            cflags = config.build_settings['OTHER_CFLAGS'] || ['$(inherited)']
            cflags << '-fembed-bitcode'
            config.build_settings['OTHER_CFLAGS'] = cflags
        end
    end
end
