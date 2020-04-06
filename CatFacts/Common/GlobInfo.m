//
//  GlobInfo.m
//  CatFacts
//
//  Created by Pae on 12/22/15.
//  Copyright © 2015 Pae. All rights reserved.
//

#import "GlobInfo.h"
#import "kchmacros.h"

@implementation GlobInfo

@synthesize lastEmail = _lastEmail;

GlobInfo *gbInfoInstance;

+ (GlobInfo*)sharedInstance
{
    if (!gbInfoInstance) {
        gbInfoInstance = [[GlobInfo alloc] init];
        [gbInfoInstance refreshCurrentUser];
    }
    return gbInfoInstance;
}

- (NSString*)lastEmail
{
    _lastEmail = UDValue(@"lastEmail");
    return _lastEmail;
}

- (void)setLastEmail:(NSString *)lastEmail
{
    _lastEmail = lastEmail;
    UDSetValue(@"lastEmail", _lastEmail);
    UDSync();
}


#pragma mark - User Account

- (void)refreshCurrentUser
{
    self.objCurrentUser = [PFUser currentUser];
    if(self.objCurrentUser == nil){
        NSLog(@"self.objCurrentUser == nil");
    }
    else {
        [gbInfoInstance.objCurrentUser fetchInBackground];
    }
}


- (BOOL)isLoggedIn{
    if (self.objCurrentUser) {
        return YES;
    }
    return NO;
}

@end

