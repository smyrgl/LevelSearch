//
//  LSStringTokenizer.h
//  
//
//  Created by John Tumminaro on 4/17/14.
//
//

#import <Foundation/Foundation.h>

@interface LSStringTokenizer : NSObject

@property (nonatomic, copy) NSSet *stopWords;

- (NSSet *)tokenizeString:(NSString *)string;

@end
