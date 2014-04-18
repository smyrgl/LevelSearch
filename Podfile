workspace 'LevelSearch'
xcodeproj 'Example/LevelSearchExample.xcodeproj'
xcodeproj 'Tests/LevelSearchTests.xcodeproj'

inhibit_all_warnings!

target :LevelSearchExample do 
	pod 'Objective-LevelDB'
	xcodeproj 'Example/LevelSearchExample.xcodeproj'
end

target :LevelSearchTests do 
	pod 'Objective-LevelDB'
	pod 'MagicalRecord'
  pod 'XCAsyncTestCase'
	xcodeproj 'Tests/LevelSearchTests.xcodeproj'
end