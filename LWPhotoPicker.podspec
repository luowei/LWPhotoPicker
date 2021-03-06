#
# Be sure to run `pod lib lint LWPhotoPicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LWPhotoPicker'
  s.version          = '1.0.0'
  s.summary          = '照片选择器，支持保留宽高比与固定宽高比两种类型选择视图.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
LWPhotoPicker，照片选择器，支持保留宽高比与固定宽高比两种类型选择视图.
                       DESC

  s.homepage         = 'https://github.com/luowei/LWPhotoPicker'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'luowei' => 'luowei@wodedata.com' }
  s.source           = { :git => 'https://github.com/luowei/LWPhotoPicker.git'}
  # s.source           = { :git => 'https://gitlab.com/ioslibraries1/libphotopicker.git' }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'LWPhotoPicker/Classes/**/*'
  
  # s.resource_bundles = {
  #   'LWPhotoPicker' => ['LWPhotoPicker/Assets/*.png']
  # }

  s.public_header_files = 'LWPhotoPicker/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'

  s.dependency 'Masonry'
  s.dependency 'YYCache'

end
