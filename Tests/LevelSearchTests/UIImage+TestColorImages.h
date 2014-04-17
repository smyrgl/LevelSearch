//
//  UIImage+TestColorImages.h
//  LevelSearchTests
//
//  Created by John Tumminaro on 4/14/14.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (TestColorImages)

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color withFrame:(CGRect)frame;
+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size;

@end
