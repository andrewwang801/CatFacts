
#import "CommData.h"
#import "kchmacros.h"
#import "DateTools.h"
#import "CatFacts-Swift.h"

@implementation CommData

+(void)showAlert:(NSString*)aMsg withTitle:(NSString*)aTitle Action:(void (^)(UIAlertAction *action))handler{
    UIAlertController *_viewAlert = [UIAlertController alertControllerWithTitle:aTitle message:aMsg preferredStyle:UIAlertControllerStyleAlert];
    [_viewAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:handler]];
    
    AppDelegate * delegate = (AppDelegate * )[UIApplication sharedApplication].delegate;
    [delegate.window.rootViewController presentViewController:_viewAlert animated:YES completion:nil];
}

+(void)showAlertWithActions:(NSString*)aMsg withTitle:(NSString*)aTitle OKAction:(void (^)(UIAlertAction *actionOK))handlerOK CancelAction:(void (^)(UIAlertAction *actionCancel))handlerCancel{
    
    UIAlertController *_viewAlert = [UIAlertController alertControllerWithTitle:aTitle message:aMsg preferredStyle:UIAlertControllerStyleAlert];
    
    [_viewAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:handlerCancel]];
    
    [_viewAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:handlerOK]];
    
    AppDelegate * delegate = (AppDelegate * )[UIApplication sharedApplication].delegate;
    [delegate.window.rootViewController presentViewController:_viewAlert animated:YES completion:nil];
}

+(void)showAlertFromView:(UIViewController*)aView Message:(NSString*)aMsg withTitle:(NSString*)aTitle Action:(void (^)(UIAlertAction *action))handler{
    UIAlertController *_viewAlert = [UIAlertController alertControllerWithTitle:aTitle message:aMsg preferredStyle:UIAlertControllerStyleAlert];
    [_viewAlert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:handler]];
    [aView presentViewController:_viewAlert animated:YES completion:nil];
}

+ (NSString*)getOnlyDateString:(NSDate*)aDate
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeStyle:NSDateFormatterNoStyle];
    [df setDateStyle:NSDateFormatterShortStyle];
    return [df stringFromDate:aDate];
}

+ (NSString*)getOnlyTimeString:(NSDate*)aDate
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeStyle:NSDateFormatterShortStyle];
    [df setDateStyle:NSDateFormatterNoStyle];
    return [df stringFromDate:aDate];
}

+ (NSString*)getDateTimeString:(NSDate*)aDate
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setTimeStyle:NSDateFormatterShortStyle];
    [df setDateStyle:NSDateFormatterShortStyle];
    return [df stringFromDate:aDate];
}

+ (void)hightLightCell:(UICollectionViewCell*)cell Highlight:(BOOL)aHigh{
    if (aHigh) {
        cell.transform = CGAffineTransformIdentity;
        [UIView animateWithDuration:0.1 animations:^{
            cell.transform = CGAffineTransformMakeScale(1.05,1.05);
        }];
    }
    else{
        [UIView animateWithDuration:0.1 animations:^{
            cell.transform = CGAffineTransformIdentity;
        }];
    }
}

+ (BOOL)validateField:(UITextField*)aText{
    if (aText.text.length == 0) {
        return NO;
    }
    return YES;
}


+ (BOOL)validateFieldMaxLength:(UITextField*)aText{
    if (aText.text.length > 1000) {
        return NO;
    }
    return YES;
}

+ (NSString*)getPriceWithUnit:(NSInteger)aPrice{
    double _fValue;
    NSString *_strUnit = @"";
    if (aPrice >= 1000000) {
        _fValue = (double)aPrice / (double)1000000;
        _strUnit = @"m";
    }
    else {
        _fValue = (double)aPrice / (double)1000;
        _strUnit = @"k";
    }
    
    return [NSString stringWithFormat:@"%.1f%@",_fValue,_strUnit];
}

+ (NSString*)getAuctionDetailWith:(PFObject*)aObject{
    NSString *_strRet;
    NSInteger _nMinPrice = [aObject[@"priceMin"] integerValue];
    NSInteger _nMaxPrice = [aObject[@"priceMax"] integerValue];
    _strRet = [NSString stringWithFormat:@"%d bed  %d bath  %d park  $%@-%@",[aObject[@"bedrooms"] intValue],[aObject[@"bathrooms"] intValue],[aObject[@"carparks"] intValue],[CommData getPriceWithUnit:_nMinPrice],[CommData getPriceWithUnit:_nMaxPrice]];
    return _strRet;
}

+ (NSString*)getAuctionPriceWith:(PFObject*)aObject{
    NSString *_strRet;
    NSInteger _nMinPrice = [aObject[@"priceMin"] integerValue];
    NSInteger _nMaxPrice = [aObject[@"priceMax"] integerValue];
    _strRet = [NSString stringWithFormat:@"$%@-%@",[CommData getPriceWithUnit:_nMinPrice],[CommData getPriceWithUnit:_nMaxPrice]];
    NSString *_strOption = aObject[@"priceOption"];
    if (_strOption != nil &&  _strOption.length > 0 ) {
        return _strOption;
    }
    return _strRet;
}

+ (NSString*)getLeftTimeFromNow:(NSDate*)aDate{
    NSDate *_dateToday = [NSDate date];
    NSDate *_dateTodayStart = [NSDate dateWithYear:_dateToday.year month:_dateToday.month day:_dateToday.day hour:0 minute:0 second:0];
    NSDate *_dateAuctionStart = [NSDate dateWithYear:aDate.year month:aDate.month day:aDate.day hour:0 minute:0 second:0];
    
    
    int _nUntil = (int)[_dateAuctionStart yearsLaterThan:_dateTodayStart];
    if (_nUntil > 0) {
        return [NSString stringWithFormat:@"%d\nYears",_nUntil];
    }

    _nUntil = (int)[_dateAuctionStart monthsLaterThan:_dateTodayStart];
    if (_nUntil > 0) {
        return [NSString stringWithFormat:@"%d\nMonths",_nUntil];
    }
    
    _nUntil = (int)[_dateAuctionStart daysLaterThan:_dateTodayStart];
    
    if (_nUntil > 0 && [aDate daysUntil] > 0) {
        return [NSString stringWithFormat:@"%d\nDays",_nUntil];
    }
    
    _nUntil = (int)[aDate hoursUntil];
    if (_nUntil > 0) {
        return [NSString stringWithFormat:@"%d\nHours",_nUntil];
    }
    
    _nUntil = (int)[aDate minutesUntil];
    if (_nUntil > 0) {
        return [NSString stringWithFormat:@"%d\nMins",_nUntil];
    }
    
    _nUntil = (int)[aDate secondsUntil];
    if (_nUntil > 0) {
        return [NSString stringWithFormat:@"%d\nSecs",_nUntil];
    }
    
    return @"Past";
}

+ (NSDate *)getDateFromNumber:(NSNumber*)aNumberDate{
    NSDate *_dateAuction = [NSDate dateWithTimeIntervalSince1970:[aNumberDate doubleValue]];
    return _dateAuction;
}
@end
