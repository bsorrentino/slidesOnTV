# Podfile
#platform :ios, '9.0'
platform :tvos, '12.4'
use_frameworks!
project 'slides.xcodeproj'

target 'slides' do
    pod 'RxSwift',    '5.1.1'
    pod 'RxCocoa',    '5.1.1'
    pod 'RxSwiftExt', '5.2.0'
    pod 'SnapKit',    '5.0.1'
    #pod 'SettingsKit'
    pod 'SettingsKit', :git => 'https://github.com/bsorrentino/SettingsKit.git', :branch => 'develop'
    #pod 'TVOSToast', '0.9'
    pod 'TVOSToast', :git => 'https://github.com/bsorrentino/TVOSToast.git', :tag => "v1.0"
end

target 'slidesTests' do
    pod 'RxBlocking', '5.1.1'
    pod 'RxTest',     '5.1.1'
end

target 'slidesUITests' do
    pod 'RxBlocking', '5.1.1'
    pod 'RxTest',     '5.1.1'
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
