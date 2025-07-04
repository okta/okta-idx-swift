Pod::Spec.new do |spec|
  spec.name             = 'OktaIdx'
  spec.version          = '3.2.5'
  spec.summary          = '[DEPRECATED] Please use the OktaIdxAuth pod instead.'
  spec.description      = 'This pod has been replaced by OktaIdxAuth.'
  spec.deprecated = true
  spec.deprecated_in_favor_of = 'OktaIdxAuth'

  spec.platforms = {
    :ios     => "10.0",
    :tvos    => "10.0",
    :watchos => "7.0",
    :osx     => "10.12"
  }
  spec.ios.deployment_target     = "10.0"
  spec.tvos.deployment_target    = "10.0"
  spec.watchos.deployment_target = "7.0"
  spec.osx.deployment_target     = "10.12"

  spec.homepage         = 'https://github.com/okta/okta-idx-swift'
  spec.license          = { :type => 'APACHE2', :file => 'LICENSE' }
  spec.authors          = { "Okta Developers" => "developer@okta.com"}
  spec.source           = { :git => 'https://github.com/okta/okta-idx-swift.git', :tag => spec.version.to_s }

  spec.source_files = 'Sources/OktaIdx/**/*.swift'
  spec.resource_bundles = { 'OktaIdx' => 'Sources/OktaIdx/Resources/**/*' }
  spec.swift_version = "5.6"

  spec.dependency "OktaAuthFoundation", "~> 1.8.2"
end
