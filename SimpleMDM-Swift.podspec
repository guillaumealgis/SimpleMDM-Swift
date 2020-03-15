#
# Be sure to run `pod lib lint SimpleMDM-Swift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SimpleMDM-Swift'
  s.module_name      = 'SimpleMDM'
  s.version          = '0.7.0'
  s.summary          = 'Swift bindings for the SimpleMDM API.'

  s.description      = <<-DESC
SimpleMDM-Swift is a cross-platform (iOS, macOS, tvOS, watchOS) SDK to access the SimpleMDM API written in Swift.

Please Note: This library is not officially supported by SimpleMDM. It does not currently wrap the complete functionality of the SimpleMDM API. Use at your own risk.
                       DESC

  s.homepage         = 'https://github.com/guillaumealgis/simplemdm-swift'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'Guillaume Algis' => 'guillaume.algis@gmail.com' }
  s.source           = { :git => 'https://github.com/guillaumealgis/simplemdm-swift.git', :tag => s.version.to_s }
  s.documentation_url = 'https://guillaumealgis.github.io/SimpleMDM-Swift/'
  s.social_media_url = 'https://twitter.com/guillaumealgis'

  s.swift_versions = [
    '5.0',
    '5.0.1'
  ]

  s.ios.deployment_target = '11.0'
  s.osx.deployment_target  = '10.13'
  s.tvos.deployment_target  = '11.0'
  s.watchos.deployment_target  = '4.0'

  s.dependency 'PromiseKit/CorePromise', "= 6.9"

  s.source_files = 'Sources/**/*.swift'
end
