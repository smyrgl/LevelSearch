//
//  UIImage+TestColorImages.m
//  LevelSearchTests
//
//  Created by John Tumminaro on 4/14/14.
//
//

#import "UIImage+TestColorImages.h"

@implementation UIImage (TestColorImages)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    return [self imageWithColor:color withFrame:CGRectMake(0, 0, 1, 1)];
}

+ (UIImage *)imageWithColor:(UIColor *)color withFrame:(CGRect)frame
{
    CGRect rect = frame;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
    
}

+ (UIImage *)imageWithColor:(UIColor *)color andSize:(CGSize)size
{
    UIImage *img = nil;
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,
                                   color.CGColor);
    CGContextFillRect(context, rect);
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

@end
