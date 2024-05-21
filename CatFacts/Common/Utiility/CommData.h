
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface CommData : NSObject

+(void)showAlert:(NSString*)aMsg withTitle:(NSString*)aTitle Action:(void (^)(UIAlertAction *action))handler;
+(void)showAlertWithActions:(NSString*)aMsg withTitle:(NSString*)aTitle OKAction:(void (^)(UIAlertAction *actionOK))handlerOK CancelAction:(void (^)(UIAlertAction *actionCancel))handlerCancel;

+(void)showAlertFromView:(UIViewController*)aView Message:(NSString*)aMsg withTitle:(NSString*)aTitle Action:(void (^)(UIAlertAction *action))handler;
+ (NSString*)getOnlyDateString:(NSDate*)aDate;
+ (NSString*)getOnlyTimeString:(NSDate*)aDate;
+ (NSString*)getDateTimeString:(NSDate*)aDate;
+ (void)hightLightCell:(UICollectionViewCell*)cell Highlight:(BOOL)aHigh;
+ (BOOL)validateField:(UITextField*)aText;
+ (BOOL)validateFieldMaxLength:(UITextField*)aText;
+ (NSString*)getAuctionDetailWith:(PFObject*)aObject;
+ (NSString*)getPriceWithUnit:(NSInteger)aPrice;
+ (NSString*)getLeftTimeFromNow:(NSDate*)aDate;
+ (NSDate *)getDateFromNumber:(NSNumber*)aNumberDate;
+ (NSString*)getAuctionPriceWith:(PFObject*)aObject;

@end
 