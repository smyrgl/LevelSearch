workspace 'LevelSearch'
xcodeproj 'Example/LevelSearchExample.xcodeproj'
xcodeproj 'Tests/LevelSearchTests.xcodeproj'
xcodeproj 'Benchmarking/LevelSearchBenchmarking.xcodeproj'

inhibit_all_warnings!

target :LevelSearchExample do
    platform :ios, '7.0'
	pod 'Objective-LevelDB'
	xcodeproj 'Example/LevelSearchExample.xcodeproj'
end

target :LevelSearchTests do
    platform :ios, '7.0'
	pod 'Objective-LevelDB'
	pod 'MagicalRecord'
    pod 'XCAsyncTestCase'
	xcodeproj 'Tests/LevelSearchTests.xcodeproj'
end

target :LevelSearchBenchmarking do
    platform :osx, '10.9'
	pod 'RestKit'
	pod 'RestKit/Search'
	pod 'MagicalRecord'
	pod 'FMDB'
	pod 'sqlite3'
    pod 'sqlite3/fts'
	pod 'Objective-LevelDB'
    pod 'CocoaLumberjack'
	xcodeproj 'Benchmarking/LevelSearchBenchmarking.xcodeproj'
end