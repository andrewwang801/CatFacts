//
//  GlobInfo.h
//  CatFacts
//
//  Created by Pae on 12/22/15.
//  Copyright © 2015 Pae. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

#define PATH_TMPIMG @"Library/Caches"

#define FONTREGULAR(x)  [UIFont fontWithName:@"Avenir-Book" size:x]
#define FONTBOLD(x)    [UIFont fontWithName:@"Avenir-Black" size:x]
#define FONTMEDIUM(x)    [UIFont fontWithName:@"Avenir-Medium" size:x]

#define DEVICE_IS_IPAD ( UIUserInterfaceIdiomPad == UI_USER_INTERFACE_IDIOM())

#define HexColor(c) [UIColor colorWithRed:((c>>24)&0xFF)/255.0 green:((c>>16)&0xFF)/255.0 blue:((c>>8)&0xFF)/255.0 alpha:((c)&0xFF)/255.0]
#define COLOR_PRIMARY HexColor(0x3F9DD9ff)

#define KICKFLIP_API_KEY @"FSAfie80NNGW_W?vQDkhPUr9cyo9I_Sh6Le_.C6h"
#define KICKFLIP_API_SECRET @"AuLh7IZObnzrmln_5JXRdWa@sgPVUR1Uj2ea7MGZdPStgbYXjcNz=LFL0pCv@2Ed8nqJ1F_aUFI2@.sz;vFMxD6oau@KbRiNM3fEK0Gth:vLp:GD0pqLx;3KqGyG_=bs"

//typedef void (^ActionClickBlock)(PFObject* aObjContact,NSInteger aRow);

@interface GlobInfo : NSObject

//@property(nonatomic,strong) NSString *lastUpdate;
@property(nonatomic,strong) NSString *lastEmail;
@property(nonatomic,strong) NSData *deviceTokenData;
@property (nonatomic,strong) PFUser * objCurrentUser;

+ (GlobInfo*)sharedInstance;
- (void)refreshCurrentUser;
- (BOOL)isLoggedIn;

@end
