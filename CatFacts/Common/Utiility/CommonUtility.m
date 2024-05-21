//
//  CommonUtility.m
//  SizeVid
//
//  Created by Abdul Rehman on 14/10/2014.
//  Copyright (c) 2014 totoventures. All rights reserved.
//

#import "CommonUtility.h"

@implementation CommonUtility

@end


@implementation UIColor (HEXString)


+ (UIColor *)colorFromHexString:(NSString *)hexString {
    return [self colorFromHexString:hexString alpha:1.0];
}

+ (UIColor *)colorFromHexString:(NSString *)hexString alpha:(CGFloat)alpha {
    //src: http://byronsalau.com/blog/how-to-convert-a-html-hex-string-into-uicolor-with-objective-c
    //also: http://stackoverflow.com/a/12397366/336422
    //Default
    UIColor *defaultResult = [UIColor blackColor];
    
    //Strip prefixed # hash, make the string
    hexString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    //Determine if 3 or 6 digits
    NSUInteger componentLength = 0;
    if ([hexString length] == 3)
    {
        componentLength = 1;
    }
    else if ([hexString length] == 6)
    {
        componentLength = 2;
    }
    else
    {
        DLog(@"Can not determine hex format");
        return defaultResult;
    }
    
    BOOL isValid = YES;
    CGFloat components[3];
    
    //Seperate the R,G,B values
    for (NSUInteger i = 0; i < 3; i++) {
        NSString *component = [hexString substringWithRange:NSMakeRange(componentLength * i, componentLength)];
        if (componentLength == 1) {
            component = [component stringByAppendingString:component];
        }
        
        NSScanner *scanner = [NSScanner scannerWithString:component];
        unsigned int value;
        isValid &= [scanner scanHexInt:&value];
        components[i] = (CGFloat)value / 255.0f;
    }
    
    if (!isValid) {
        DLog(@"Can not read hex values");
        return defaultResult;
    }
    
    return [UIColor colorWithRed:components[0]
                           green:components[1]
                            blue:components[2]
                           alpha:alpha];
}

@end
