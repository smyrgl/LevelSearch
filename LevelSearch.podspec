Pod::Spec.new do |s|
  s.name             = "LevelSearch"
  s.version          = "0.1.4.1"
  s.summary          = "Full text search for Core Data based on LevelDB"
  s.license          = 'MIT'
  s.author           = { "John Tumminaro" => "john@tinylittlegears.com" }
  s.homepage         = 'https://github.com/smyrgl/LevelSearch'
  s.source           = { :git => "https://github.com/smyrgl/LevelSearch.git", :tag => s.version.to_s }

  s.ios.deployment_target = '7.0'
  s.osx.deployment_target = '10.9'
  s.requires_arc = true

  s.source_files = 'Classes'
  s.resource_bundles = { 'LevelSearchAssets' => 'Assets/*.txt' }
  s.public_header_files = 'Classes/*.h'
  s.frameworks = 'Foundation', 'CoreData'
  s.dependency 'Objective-LevelDB', '~> 2.1.5'
  s.dependency 'MessagePack', '~> 1.0.0'

end
