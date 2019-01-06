#
# Be sure to run `pod lib lint KVRefreshable.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KVRefreshable'
  s.version          = '1.6'
  s.summary          = 'KVRefreshable for Swift.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/vuvankhac/KVRefreshable'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Vu Van Khac' => 'khacvv0451@gmail.com' }
  s.source           = { :git => 'https://github.com/vuvankhac/KVRefreshable.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/vuvankhac'

  s.ios.deployment_target = '10.0'
  s.swift_version = '4.2'

  s.source_files = 'KVRefreshable/Classes/**/*'
  
  # s.resource_bundles = {
  #   'KVRefreshable' => ['KVRefreshable/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
