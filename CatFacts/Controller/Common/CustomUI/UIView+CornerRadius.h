//
//  UIView+CornerRadius.h
//  CatFacts
//
//  Created by Pae on 12/18/15.
//  Copyright © 2015 Pae. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (CornerRadius)
- (void)setCornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)width borderColor:(UIColor *)color;

@property (nonatomic, copy, readonly) NSString * value;
@end
