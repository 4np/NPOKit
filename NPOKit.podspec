Pod::Spec.new do |spec|
  spec.name = 'NPOKit'
  spec.version = '0.0.9'
  spec.summary = 'NPOKit framework for interfacing with the Dutch Public Broadcaster'
  spec.homepage = 'https://github.com/4np/NPOKit'
  spec.license = { type: 'APACHE', file: 'LICENSE' }
  spec.authors = { "Jeroen Wesbeek" => 'github@osx.eu' }
  spec.documentation_url = 'https://github.com/4np/NPOKit/blob/master/README.md'

  spec.platforms = { :ios => '11.0', :osx => '12.0', :tvos => '11.0' }
  spec.requires_arc = true
  spec.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.1' }
  spec.source = { :git => 'https://github.com/4np/NPOKit.git', :tag => "#{spec.version}" }

  spec.source_files = 'Sources/**/*.{swift}'
  spec.resources = 'Sources/**/*.{lproj,storyboard,xcdatamodeld,xib,xcassets,json}'
#  spec.resource_bundles = {
#    'NPOKit' => ['Sources/**/*.{lproj,storyboard,xcdatamodeld,xib,xcassets,json}', 'Sources/NPOKit/*.xcassets']
#  }

  #spec.default_subspecs = 'Core'
  #
  #spec.subspec 'Core' do |core|
  #  core.source_files = 'Sources/NPOKit/**/*.{swift}'
  #end
end
