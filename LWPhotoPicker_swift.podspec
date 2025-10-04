#
# Be sure to run `pod lib lint LWPhotoPicker_swift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LWPhotoPicker_swift'
  s.version          = '1.0.0'
  s.summary          = 'LWPhotoPicker Swift version - Photo picker with aspect ratio support written in Swift.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
LWPhotoPicker Swift version - This is the Swift submodule of LWPhotoPicker containing photo picker components written in Swift. Supports both preserve aspect ratio and fixed aspect ratio photo selection views.
                       DESC

  s.homepage         = 'https://github.com/luowei/LWPhotoPicker'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'luowei' => 'luowei@wodedata.com' }
  s.source           = { :git => 'https://github.com/luowei/LWPhotoPicker.git'}
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.swift_version = '5.0'

  s.source_files = 'LWPhotoPicker_swift/SwiftClasses/**/*'

  # s.resource_bundles = {
  #   'LWPhotoPicker_swift' => ['LWPhotoPicker_swift/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

  s.dependency 'Masonry'
  s.dependency 'YYCache'
end
