//
//  CommonUtility.h
//  SizeVid
//
//  Created by Abdul Rehman on 14/10/2014.
//  Copyright (c) 2014 totoventures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define AV_TITLE_INFO           @"Slo Mo Video"


// DLog will output like NSLog only when the DEBUG variable is set

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

// ALog will always output like NSLog

#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);


#define ISIPHONE169             ([UIScreen mainScreen].bounds.size.height >= 568 && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? YES : NO

#define ISIPHONE43             ([UIScreen mainScreen].bounds.size.height == 480 ? YES : NO)

#if !IS_PRO
static NSString * kUDHasReviewedApp = @"kUDHasReviewedApp";
static NSString * kAppStoreId       = @"950551948";

static NSString *kProduct_IRMode = @"ReverseVidInstantReplayMode";
static NSString *kNotificationStoreStateChanged = @"kNotificationStoreStateChanged";
#endif


static const NSTimeInterval DEFAULT_ANIMATION_DURATION = 0.3;

@interface CommonUtility : NSObject

@end


@interface UIColor (HEXString)

+ (UIColor *)colorFromHexString:(NSString *)hexString;
+ (UIColor *)colorFromHexString:(NSString *)hexString alpha:(CGFloat)alpha;

@end