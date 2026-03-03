#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint error_monitor.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'error_monitor'
  s.version          = '1.0.0'
  s.summary          = 'Production-ready crash tracking for Flutter. Zero Firebase dependency.'
  s.description      = <<-DESC
Ship crash reports to any REST API with offline queue, breadcrumbs,
session tracking, device context, and fingerprint-based issue grouping.
                       DESC
  s.homepage         = 'https://github.com/mdnahidhossen1911/error_monitor'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Md Nahid Hossen' => 'mdnahidhossen1911@gmail.com' }

  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'

  # If your plugin requires a privacy manifest, for example if it collects user
  # data, update the PrivacyInfo.xcprivacy file to describe your plugin's
  # privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'error_monitor_privacy' => ['Resources/PrivacyInfo.xcprivacy']}

  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
