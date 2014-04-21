# LevelSearch CHANGELOG

## 0.1.3
- Switched back to an inverted index.  Indexing time goes up but search performance is drastically improved.
- Breaks compatibility with indexes built against earlier versions.

## 0.1.2
- After profiling some alternate formats for binary serialization it seems that MessagePack has won out over JSON.  The improvement in query and file size over JSON is ~50%.
- Switching to MessagePack has resulted in an order-of-magnitude increase in query performance over using NSKeyedArchiving.  This was expected.  
- Breaks compatibility with indexes built against earlier versions.

## 0.1.1
- Added performance testing project for profiling the different search implementations.
- Performance improvements based on some initial findings.

## 0.1.0

Initial release.
