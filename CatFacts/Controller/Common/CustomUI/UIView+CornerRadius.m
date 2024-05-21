//
//  UIView+CornerRadius.m
//  CatFacts
//
//  Created by Pae on 12/18/15.
//  Copyright © 2015 Pae. All rights reserved.
//

#import "UIView+CornerRadius.h"

@implementation UIView (CornerRadius)
- (void)setCornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)width borderColor:(UIColor *)color{
    self.layer.cornerRadius = cornerRadius;
    self.layer.borderWidth = width;
    self.layer.borderColor = color.CGColor;
    self.layer.masksToBounds = true;
}

- (NSString *)value{
    return @"";
}
@end
