//
//  LSStringTokenizer.m
//  
//
//  Created by John Tumminaro on 4/17/14.
//
//

#import "LSStringTokenizer.h"

@implementation LSStringTokenizer

- (NSSet *)tokenizeString:(NSString *)string
{
    NSMutableSet *tokens = [NSMutableSet set];
    
    CFLocaleRef locale = CFLocaleCopyCurrent();
    
    NSString *tokenizeText = string = [string stringByFoldingWithOptions:kCFCompareCaseInsensitive|kCFCompareDiacriticInsensitive locale:[NSLocale systemLocale]];
    CFStringTokenizerRef tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, (__bridge CFStringRef)tokenizeText, CFRangeMake(0, CFStringGetLength((__bridge CFStringRef)tokenizeText)), kCFStringTokenizerUnitWord, locale);
    CFStringTokenizerTokenType tokenType = kCFStringTokenizerTokenNone;
    
    while (kCFStringTokenizerTokenNone != (tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer))) {
        CFRange tokenRange = CFStringTokenizerGetCurrentTokenRange(tokenizer);
        
        NSRange range = NSMakeRange(tokenRange.location, tokenRange.length);
        NSString *token = [string substringWithRange:range];
        
        [tokens addObject:token];
    }
    
    CFRelease(tokenizer);
    CFRelease(locale);
    
    if (self.stopWords) [tokens minusSet:self.stopWords];
    
    return tokens;

}

@end
