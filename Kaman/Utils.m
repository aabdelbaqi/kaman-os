//
//  Utils.m
//  Say-QR
//
//  Created by Moin' Victor on 28/10/2015.
//  Copyright © 2015 Onnox. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utils.h"
#import "LocalNotif.h"
#import "PFObject+KamanCat.h"
#import "TermsViewController.h"

@implementation NSString (emailValidation)
-(BOOL)isValidEmail
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:self];
}
@end

@implementation Utils

+ (void)runBlock:(void (^)())block
{
    block();
}
+ (void)runAfterDelay:(CGFloat)delay block:(void (^)())block
{
    void (^block_)() = [block copy];
    [self performSelector:@selector(runBlock:) withObject:block_ afterDelay:delay];
}

//Class.m
+ (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

+(void) showMessageHUDInView:(UIView*) view withMessage:(NSString*) msg afterError:(BOOL) isError
{
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = msg;
    if(isError){
        HUD.indicatorView = [[JGProgressHUDErrorIndicatorView alloc] init]; //JGProgressHUDSuccessIndicatorView is also available
    } else {
          HUD.indicatorView = [[JGProgressHUDSuccessIndicatorView alloc] init]; //
    }
    [HUD showInView:view];
    [HUD dismissAfterDelay:3.0];
}

+(JGProgressHUD*) showProgressDialogInView: (UIView*) view withMessage :(NSString*) msg
{
    JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
    HUD.textLabel.text = msg;
    [HUD showInView:view];
    [HUD dismissAfterDelay:25.0];
    return HUD;
}
+(void) bottomBorderOnly: (UITextField*) textField
{
    textField.borderStyle = UITextBorderStyleNone;
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 1;
    border.borderColor = MyBrownColor.CGColor;
    border.frame = CGRectMake(0, textField.frame.size.height - borderWidth, textField.frame.size.width, textField.frame.size.height);
    border.borderWidth = borderWidth;
    [textField.layer addSublayer:border];
    textField.layer.masksToBounds = YES;

}

+ (NSInteger)hoursBetween:(NSDate *)firstDate and:(NSDate *)secondDate
{
    NSUInteger unitFlags = NSCalendarUnitHour;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:unitFlags fromDate:firstDate toDate:secondDate options:0];
    return [components hour]+1;
}

+(NSDateFormatter*) getDateFormatter_MMM_D
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:posix];
    [formatter setDateFormat:@"MMM dd"];
    return formatter;
}

+(NSDateFormatter*) getDateFormatter_DD_MMMM_YYYY
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:posix];
    [formatter setDateFormat:@"dd MMMM, y"];
    return formatter;
}

+(NSDateFormatter*) getTimeFormatter_H_MM_AMPM
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:posix];
    [formatter setDateFormat:@"h:mm a"];
    return formatter;
}

+(NSDate*) dateFromStringWithSec: (NSString*) YYYYY_MM_dd_HH_mm_ss
{
    NSDateFormatter *dataFormatter = [[NSDateFormatter alloc] init];
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dataFormatter setLocale:posix];
    [dataFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dataFormatter dateFromString: YYYYY_MM_dd_HH_mm_ss];
}

+(NSString*) YYYYY_MM_dd_HH_mm_ss_FromDate: (NSDate*) date
{
    NSDateFormatter *dataFormatter = [[NSDateFormatter alloc] init];
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dataFormatter setLocale:posix];
    [dataFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return [dataFormatter stringFromDate:date];
}

+(NSDate*) dateFromString: (NSString*) YYYYY_MM_dd_HH_mm
{
    NSDateFormatter *dataFormatter = [[NSDateFormatter alloc] init];
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dataFormatter setLocale:posix];
    [dataFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    return [dataFormatter dateFromString: YYYYY_MM_dd_HH_mm];
}

+(NSDate*) localDate: (NSDate*) date
{
    NSDateFormatter *dataFormatter = [[NSDateFormatter alloc] init];
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dataFormatter setLocale:posix];
    [dataFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
    return [dataFormatter dateFromString: [dataFormatter stringFromDate:date]];
}

+(NSString*) formatDate: (NSDate*) date
{
    NSDateFormatter *dataFormatter = [[NSDateFormatter alloc] init];
    NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [dataFormatter setLocale:posix];
    [dataFormatter setDateFormat:@"yyyy-MM-dd 'at' HH:mm"];
    return [dataFormatter stringFromDate:date];
}

+ (NSDate *)combineDate:(NSDate *)date withTime:(NSDate *)time {
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:
                             NSCalendarIdentifierGregorian];
    
    unsigned unitFlagsDate = NSCalendarUnitYear | NSCalendarUnitMonth
    |  NSCalendarUnitDay;
    NSDateComponents *dateComponents = [gregorian components:unitFlagsDate
                                                    fromDate:date];
    unsigned unitFlagsTime = NSCalendarUnitHour | NSCalendarUnitMinute;
    //|  NSSecondCalendarUnit;
    NSDateComponents *timeComponents = [gregorian components:unitFlagsTime
                                                    fromDate:time];
    
    [dateComponents setSecond:[timeComponents second]];
    [dateComponents setHour:[timeComponents hour]];
    [dateComponents setMinute:[timeComponents minute]];
    
    NSDate *combDate = [gregorian dateFromComponents:dateComponents];   
    
    return combDate;
}

+ (void)setPresentationStyleForSelfController:(UIViewController *)selfController presentingController:(UIViewController *)presentingController
{
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
    {
        presentingController.providesPresentationContextTransitionStyle = YES;
        presentingController.definesPresentationContext = YES;
        
        [presentingController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    }
    else
    {
        [selfController setModalPresentationStyle:UIModalPresentationCurrentContext];
        [selfController.navigationController setModalPresentationStyle:UIModalPresentationCurrentContext];
    }
}


+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+(void) updateCurrentPFUserColumn: (NSString*) column withValue: (id) value onCallBack: (ResultCallback) callback
{
    [self updatePFUser:[PFUser currentUser] onColumn:column withValue:value onCallBack:callback];
}


+(void) updatePFUser:(PFUser*) user onColumn: (NSString*) column withValue: (id) value onCallBack: (ResultCallback) callback
{
    if(value) {
        [user setObject: value forKey:column];
        
    }
    [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
          if (!error) {
            if(callback) {
                callback(value);
            }
        }
        else{
            // Error
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];

}


+(NSString*) getPFUserAgeAsString:(PFUser*) user onNoAge :(NSString*) noAge
{
    NSDate *dob = [user objectForKey:@"DateOfBirth"];
    if(dob) {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [calendar components:NSCalendarUnitYear
                                                   fromDate:dob
                                                     toDate:[NSDate date]
                                                    options:0];
        return [NSString stringWithFormat:@"%ld", (long)components.year];
        
    } else {
        return noAge;
    }

}
+(void) styleButton: (UIButton*) button bgColor: (UIColor*) bgColor highlightColor: (UIColor*) highlightColor
{
    [self styleButton:button bgColor:bgColor highlightColor:highlightColor radius:10];
}

+(void) styleButton: (UIButton*) button bgColor: (UIColor*) bgColor highlightColor: (UIColor*) highlightColor radius: (NSInteger) radii
{
    [button setBackgroundImage:[self imageWithColor:bgColor] forState:UIControlStateNormal];
    [button setBackgroundImage:[self imageWithColor:highlightColor] forState:UIControlStateHighlighted];
    button.layer.cornerRadius = radii;
    button.clipsToBounds = YES;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

+(void) styleTextView: (UITextView*) textView
{
    [textView.layer setBackgroundColor: [[UIColor whiteColor] CGColor]];
    [textView.layer setBorderColor: [UIColorFromRGB(0xC1C1C1) CGColor]];
    [textView.layer setBorderWidth: 1.0];
    [textView.layer setCornerRadius:8.0f];
    [textView.layer setMasksToBounds:YES];
}

+(void) postfixImageNamed: (NSString*) imageName toTextField: (UITextField*) textfield
{
    UIView *prefixView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, [textfield frame].size.height - 2)];
    // (Height of UITextField is 30px so height of viewRightIntxtFieldDate = 30px)
    UIImageView *prefixImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 2 , 22, 22)];
    [prefixImage setImage:[UIImage imageNamed:imageName]];
    [prefixView addSubview:prefixImage];
    [textfield setRightViewMode:UITextFieldViewModeAlways];
    textfield.rightView = prefixView;
}


+(void) prefixImageNamed: (NSString*) imageName toTextField: (UITextField*) textfield
{
    UIView *prefixView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, [textfield frame].size.height - 2)];
    // (Height of UITextField is 30px so height of viewRightIntxtFieldDate = 30px)
    UIImageView *prefixImage = [[UIImageView alloc] initWithFrame:CGRectMake(5, 2 , 22, 22)];
    [prefixImage setImage:[UIImage imageNamed:imageName]];
    [prefixView addSubview:prefixImage];
    [textfield setLeftViewMode:UITextFieldViewModeAlways];
    textfield.leftView = prefixView;
}

+(void) setUIView: (UIView*) uiView backgroundColor: (UIColor*) color andRoundedByRadius:(NSInteger) radius withBorderColor: (UIColor*) borderColor
{
    uiView.backgroundColor = color;
    uiView.layer.cornerRadius = radius;
    uiView.clipsToBounds = YES;
    if(borderColor) {
        [[uiView layer] setBorderWidth:1.0f];
        [[uiView layer] setBorderColor:borderColor.CGColor];
    }
}

+ (NSString *) append:(id) first, ...
{
    NSString * result = @"";
    id eachArg;
    va_list alist;
    if(first)
    {
        result = [result stringByAppendingString:first];
        va_start(alist, first);
        while ((eachArg = va_arg(alist, id)))
            result = [result stringByAppendingString:eachArg];
        va_end(alist);
    }
    return result;
}

+(void) getPlacesAroundLatitude: (double)lat longitude: (double)lon onCallback: (ResultCallback) resultCallback onError: (ErrorCallback) errorCallback
{
    
    NSDictionary* queryParams = @{@"location": [NSString stringWithFormat:@"%f,%f",lat,lon],
                                  @"key": GOOGLE_PLACES_API_KEY,
                                  @"sensor": @"true",
                                  @"types": @"airport|establishment|shopping_mall|museum|bank|amusement_park|city_hall|university|stadium|post_office|fire_station|gas_station|embassy|rv_park|campground|art_gallery|aquarium|park|subway_station|local_government_office|liquor_store",
                                  @"rankby": @"prominence",
                                  @"radius": @"10000", // upto 10 Km
                                  @"t": [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]]};
    
    NSLog(@"%@",GET_CITIES_API_ENDPOINT);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    //manager.responseSerializer = [AFJSONResponseSerializer serializer];
    [manager GET:GET_CITIES_API_ENDPOINT
      parameters:queryParams
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *dict = responseObject;
            // NSLog(@"Server Response FETCH CITIES %@", responseObject);
              NSLog(@"GOOGLE Error (if any): %@", [dict objectForKey:@"error_message"]);
             NSArray *json_array = [dict objectForKey:@"results"];
             if(resultCallback){
                resultCallback(json_array);
            }
             
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             if(errorCallback) {
                 errorCallback(error);
             }
         }];
}

+(void) parseSmartStoreKamanArea: (NSString*) area fromCountry: (NSString*) country andCountryCode: (NSString*) cCode withLocationLat: (double) lat locationLon: (double) lon onSuccess:(ResultCallback) callback onError:(ErrorCallback) errorCallback
{
    // save this locality to parse if it doesnt exists
    PFQuery *query = [PFQuery queryWithClassName:@"KamanArea"];
    [query whereKey:@"Name" equalTo:area];
    [query whereKey:@"CountryCode" equalTo:cCode];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %lu areas matching %@", (unsigned long)objects.count,area);
            if(objects.count == 0) { // no such exists
                PFObject *kamanArea = [PFObject objectWithClassName:@"KamanArea"];
                kamanArea[@"CountryCode"] = cCode;
                kamanArea[@"Country"] = country;
                kamanArea[@"Name"] = area;
                kamanArea[@"LatLong"] = [PFGeoPoint geoPointWithLatitude:lat longitude:lon];
                [kamanArea saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if(succeeded) {
                        NSLog(@"Saved new Area to parse, %@",area);
                        if (callback) {
                            callback(kamanArea);
                        }
                    } else {
                          NSLog(@"Error: %@ %@", error, [error userInfo]);
                        if (errorCallback) {
                            errorCallback(error);
                        }
                    }
                }];
                
            } else {
                PFObject *existing = [objects firstObject];
                  NSLog(@"Found existing Area with name %@ in parse,id= %@",area,existing.objectId);
                if (callback) {
                    callback(existing);
                }
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            if (errorCallback) {
                errorCallback(error);
            }

        }
        
    }];
    
}


+(void) sendPushFor:(NSString*) type toUser: (PFUser*) user withMessage:(NSString*) message ForKaman: (PFObject*) kaman
{
 
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" equalTo:user];
    [self sendPushFor:type toQuery:pushQuery withMessage:message ForKaman:kaman targetUsers:[NSArray arrayWithObject:user]];
    
}

+(void) sendPushFor:(NSString*) type toQuery: (PFQuery*) pushQuery withMessage:(NSString*) message ForKaman: (PFObject*) kaman targetUsers:(NSArray*) users
{
    PFUser * kamanHost = [kaman objectForKey:@"Host"];
    
    NSArray * ignoreTypes = @[
                              PUSH_TYPE_INVITE_ACCEPTED,
                              PUSH_TYPE_REQUEST_ACCEPTED,
                              PUSH_TYPE_RATED];
    
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithDictionary:@{
                           @"alert" : message,
                           @"badge" : @"Increment",
                           @"type" : type,
                           // @"sounds" : @"cheering.caf"
                           @"kamanId" : kaman.objectId,
                           @"kamanHostId" : kamanHost.objectId,
                           @"senderId": [PFUser currentUser].objectId,
                           @"senderName" : [[PFUser currentUser] displayName],
                           }];
    
    BOOL ignore = [ignoreTypes containsObject:type];
    if(ignore) {
        [data removeObjectForKey:@"badge"];
    }
    
    // Send push notification to query
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery]; // Set our Installation query
    [push setData:data];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error) {
             NSLog(@"Error sending push: %@",error.localizedDescription);
        }
    }];
    
    
    for (PFUser * user in users) {
        if(![user.objectId isEqualToString:[PFUser currentUser].objectId] && !ignore) {
            PFObject * notif = [PFObject objectWithClassName:@"LocalNotif"];
            notif[@"alert"] = message;
            notif[@"targetUser"] = user;
            notif[@"type"] = type;
            notif[@"Kaman"] = kaman;
            notif[@"sender"] = [PFUser currentUser];
            [notif saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(error) {
                    NSLog(@"Error while saving notification: %@",error.localizedDescription);
                } else {
                    //[user saveEventually];
                }
            }];
        }
    }

}

+(void) sendPushFor:(NSString*) type toChannel: (NSString*) channelName withMessage:(NSString*) message ForKaman: (PFObject*) kaman targetUsers:(NSArray*) users
{
    
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"channels" equalTo:channelName];
    [pushQuery whereKey:@"user" notEqualTo:[PFUser currentUser]];
    
    [self sendPushFor:type toQuery:pushQuery withMessage:message ForKaman:kaman targetUsers:users];
    /*
    PFUser * kamanHost = [kaman objectForKey:@"Host"];
    
    NSDictionary *data = @{
                           @"alert" : message,
                          // @"badge" : @"Increment",
                           @"type" : type,
                           // @"sounds" : @"cheering.caf"
                           @"kamanHostId" : kamanHost.objectId,
                           @"kamanId" : kaman.objectId,
                           @"senderId": [PFUser currentUser].objectId,
                           @"senderName" : [[PFUser currentUser] displayName],
                           };
    
    // Send push notification to query
    PFPush *push = [[PFPush alloc] init];
    [push setChannel:channelName]; // Set our channel name
    // TODO filter bt notify messages settings.
    // hint query on parse installation, filter users field by visibility and channels by provided channel name
    [push setData:data];
    [push sendPushInBackground];
     */
    
}


+(void)showInternalNotifIn:(UIViewController*) controller withTitle:(NSString*) title message:(NSString*) message
         withButtonTitle: (NSString*) buttonTitle onButtonClicked:(void (^__strong)())buttonCallback
{
   
    [TSMessage showNotificationInViewController:controller
                                          title:title
                                       subtitle:message
                                          image:nil
                                           type:TSMessageNotificationTypeMessage
                                       duration:TSMessageNotificationDurationAutomatic
                                       callback:nil
                                    buttonTitle:buttonTitle
                                 buttonCallback:buttonCallback
                                     atPosition:TSMessageNotificationPositionTop
                           canBeDismissedByUser:YES];

}


+(void) locallyStoreLocalPlace: (NSString*) placeName fromCountry: (NSString*) country andCountryCode: (NSString*) cCode withLocationLat: (double) latitude andLocationLon: (double) longitude onSuccess: (ResultCallback) callback
{
    LocalPlace *localCity = [[LocalPlace alloc] init];
    localCity.name = placeName;
    localCity.countryCode = cCode;
    localCity.countryName = country;
    localCity.lat = latitude;
    localCity.lon = longitude;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm beginWriteTransaction];
    [LocalPlace createOrUpdateInRealm:realm withValue:
     localCity];
    
    [realm commitWriteTransaction];
    
    if(callback) {
        callback(localCity);
    }
}


+(void) setTitle:(NSString *)title withColor: (UIColor*) titleColor andSubTitle: (NSString*) subTitle withColor: (UIColor*) subtitleColor onNavigationController: (UIViewController*) controller
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = titleColor;
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.text = title;
    [titleLabel sizeToFit];
    
    UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 0, 0)];
    subTitleLabel.backgroundColor = [UIColor clearColor];
    subTitleLabel.textColor = subtitleColor;
    subTitleLabel.font = [UIFont systemFontOfSize:13];
    subTitleLabel.text = subTitle;
    [subTitleLabel sizeToFit];
    
    UIView *twoLineTitleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, MAX(subTitleLabel.frame.size.width, titleLabel.frame.size.width), 30)];
    [twoLineTitleView addSubview:titleLabel];
    [twoLineTitleView addSubview:subTitleLabel];
    
    float widthDiff = subTitleLabel.frame.size.width - titleLabel.frame.size.width;
    
    if (widthDiff > 0) {
        CGRect frame = titleLabel.frame;
        frame.origin.x = widthDiff / 2;
        titleLabel.frame = CGRectIntegral(frame);
    }else{
        CGRect frame = subTitleLabel.frame;
        frame.origin.x = abs(widthDiff) / 2;
        subTitleLabel.frame = CGRectIntegral(frame);
    }
    
    controller.navigationItem.titleView = twoLineTitleView;
}

+(void) updateApplicationBadge 
{
    UIApplication * application =  [UIApplication sharedApplication];
    RLMResults<LocalNotif *> *notifs = [LocalNotif allObjects]; // retrieves all LocalNotifs from the default Realm
    NSInteger number = [notifs count];
    application.applicationIconBadgeNumber = number;
    
    if([PFInstallation currentInstallation]) {
        [PFInstallation currentInstallation].badge = number;
        [[PFInstallation currentInstallation] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(!succeeded) {
                [[PFInstallation currentInstallation] saveEventually];
            }
        }];
    }
}

+(void) fetchLocalNotifs:(ResultCallback) whenDone
{
    NSDate *lastDate;
    NSUserDefaults * prefs = [NSUserDefaults standardUserDefaults];
    NSString * lastDateStr = [prefs stringForKey:@"lastLoadDate"];
    NSString * notifsReset = [prefs stringForKey:@"notifs_reset"];
    if(lastDateStr) {
        lastDate = [Utils dateFromStringWithSec:lastDateStr];
    }
    
    if([[PFUser currentUser].objectId isEqualToString: @"1OkH6YdVsT"]) {  // if user is Jasem
        if(!notifsReset) { // and we have not reset his notifs
            [Utils deleteNotifsWithQuery:nil]; // reset all notifications
            [prefs setObject:@"1OkH6YdVsT" forKey:@"notifs_reset"];
            [prefs synchronize];
        }
    }
    PFUser * currentUser = [PFUser currentUser];
    
    PFQuery *query = [PFQuery queryWithClassName:@"LocalNotif"];
    [query includeKey:@"Kaman"];
    [query includeKey:@"targetUser"];
    [query includeKey:@"sender"];
    [query whereKey:@"targetUser" equalTo:currentUser];
    
    if(lastDate != nil) {
        [query whereKey:@"createdAt" greaterThan:lastDate];
    }
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error) {
            NSMutableArray *notifs = [NSMutableArray new];
            for (PFObject *obj in objects) {
                PFObject * kaman = [obj objectForKey:@"Kaman"];
                PFObject * sender = [obj objectForKey:@"sender"];
                PFObject * kamanHost = [kaman objectForKey:@"Host"];
                NSString * data = [obj objectForKey:@"alert"];
                NSDate * kamanDate = [kaman objectForKey:@"DateTime"];
                NSNumber *archivedNSNumber = [kaman objectForKey: @"Archived"];
                bool archived = [archivedNSNumber boolValue];
                NSArray * myArchived = [currentUser objectForKey:@"ArchivedKamans"];
                if(myArchived == nil) {
                    myArchived = @[];
                }
                BOOL notarchived = !archived && ![myArchived containsObject:kaman.objectId];
                if(notarchived) {
                    [Utils addLocalNotifOfType:obj[@"type"] fromSender:sender.objectId forKaman:kaman.objectId hostedBy:kamanHost.objectId withAlert:data dated:obj.createdAt];
                    [notifs addObject:obj];
                }
            }
            
            [prefs setObject:[Utils YYYYY_MM_dd_HH_mm_ss_FromDate:[NSDate date]] forKey:@"lastLoadDate"];
            [prefs synchronize];
            
            [Utils updateApplicationBadge];
            if(whenDone) {
                whenDone(notifs);
            }
        } else {
            NSLog(@"Error fetching local notifs: %@",error.localizedDescription);
        }
    }];
}

+(void) addLocalNotifOfType:(NSString*) type fromSender :(NSString*) senderObjId forKaman: (NSString*) kamanObjId hostedBy:(NSString*) kamanHostId withAlert:(NSString*) alert dated:(NSDate*) date
{
    
    NSLog(@"Notif Date %@",date);
    LocalNotif *notif = [[LocalNotif alloc]
                         initWithValue:@{
                                         @"type" : type,
                                         @"date" : date,
                                         @"data" : alert,
                                         @"kamanId" : kamanObjId,
                                         @"senderId":senderObjId,
                                         @"target": [kamanHostId isEqualToString:[PFUser currentUser].objectId] ? @"Host" : @"Attendee"}];
    
    notif.date = date;
    RLMRealm *realm = [RLMRealm defaultRealm];
    // You only need to do this once (per thread)
    
    // Add to Realm with transaction
    [realm beginWriteTransaction];
    [realm addObject:notif];
    [realm commitWriteTransaction];
    
    [Utils updateApplicationBadge];
    
}

+(void)deleteNotifsWithQuery:(NSString *)query
{
    // Get the default Realm
    RLMRealm *realm = [RLMRealm defaultRealm];
    
    RLMResults *notifs = query ? [LocalNotif objectsWhere:
                                  query] : [LocalNotif allObjects];
    [realm beginWriteTransaction];
    [realm deleteObjects:notifs];
    [realm commitWriteTransaction];
    [Utils updateApplicationBadge];

}


+(NSInteger) updateNotifBadgeFor:(NSString*) query toView:(UIView*) view position: (MGBadgePosition) position
{
    RLMResults<LocalNotif *> *hostNotifs = [LocalNotif objectsWhere:query];
    if(view) {
        view.badgeView.badgeValue = [hostNotifs count];
        view.badgeView.badgeColor = DesignersBrownColor;
        view.badgeView.textColor = [UIColor blackColor];
        view.badgeView.position =position;
        [view.badgeView setOutlineWidth:2.0];
        [view.badgeView setOutlineColor:MyGreyColor];
    }
    
    return [hostNotifs count];
}

+(void) sendGoogleAnalyticsTrackEventOfCategory:(NSString*) category
                                         action:(NSString*) action labeled:(NSString*)label withValue: (NSNumber*) value
{
    // May return nil if a tracker has not already been initialized with a property
    // ID.
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder
                    createEventWithCategory:category     // Event category (required)
                    action: action // Event action (required)
                    label:label          // Event label
                    value:value] build]];
}

+(void)fetchFBProfile
{
    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters: @{ @"fields" : @"id,name,first_name,email,gender,birthday,age_range,picture.width(220).height(220)"}]startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSLog(@"Fetched user:%@", result);
            NSString *nameOfLoginUser = [result valueForKey:@"first_name"];
            NSString *genderOfLoginUser = [result valueForKey:@"gender"];
            NSString *emailOfLoginUser = [result valueForKey:@"email"];
            NSString *dobOfLoginUser = [result valueForKey:@"birthday"];
            NSString *ageRangeOfLoginUser = [result valueForKey:@"age_range"];
            
            NSString *imageStringOfLoginUser = [[[result valueForKey:@"picture"] valueForKey:@"data"] valueForKey:@"url"];
            
            UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageStringOfLoginUser]]];
            if([PFUser currentUser]) {
                PFUser *user = [PFUser currentUser];
                user[@"FBUserID"] = [result objectForKey:@"id"];
                if(!user[@"Gender"] && genderOfLoginUser) {
                    user[@"Gender"] = [@"male" isEqualToString: genderOfLoginUser] ? @"Male" : @"Female";
                }
                if(!user[@"email"] && emailOfLoginUser) {
                    user[@"email"] = emailOfLoginUser;
                }
                if(!user[@"AgeRange"]) {
                    user[@"AgeRange"] = ageRangeOfLoginUser;
                }
                /* if(!user[@"DateOfBirth"]) {
                 user[@"DateOfBirth"] = emailOfLoginUser;
                 }*/
                if(nameOfLoginUser)
                    [user setObject:nameOfLoginUser forKey:@"SocialProfileName"];
                if(imageStringOfLoginUser)
                    [user setObject:imageStringOfLoginUser forKey:@"SocialProfileImage"];
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if(succeeded) {
                      //  NSLog(@"Saved FB profile to parse");
                    } else {
                       NSLog(@"Error saving FB profile: %@",error);
                    }
                }];
            }
            
        } else {
            NSLog(@"Error Fetching fb user: %@",error);
        }
    }];
    
}

+(void) fetchFBForLogedInUser
{
    [Utils fetchFBFriends];
    [Utils fetchFBProfile];
}

+(void) fetchFBFriends
{
    // Get friends
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:@"/me/friends"
                                  parameters: @{ @"fields" : @"id,name"}
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        if(!error) {
            // Handle the result
            NSArray * friends = [result objectForKey:@"data"];
            PFUser *user = [PFUser currentUser];
            for (NSDictionary *friend in friends) {
                [user addUniqueObject:[friend objectForKey:@"id"] forKey:@"FBFriendsUserIDs"];
                // NSLog(@"%@ - %@", [friend objectForKey:@"name"],[friend objectForKey:@"id"]);
            }
            if([friends count] > 0) {
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if(succeeded) {
                     //   NSLog(@"Saved FB friends to parse");
                    } else {
                        NSLog(@"Error saving FB Friendlist: %@",error);
                    }
                }];
            }
        } else {
            NSLog(@"Error Fetching FB FriendsList: %@",error);
            if([Utils connected]) {
               // [self findFBFriends];
            }
        }
    }];
 
}

+(void) goToTerms:(UIViewController*) controller skipToPrivacy:(BOOL) skipToPrivacy
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    TermsViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"terms"];
    //set properties
    viewController.showCommercial = skipToPrivacy;
    UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:viewController];
    [navCon.navigationBar setBarTintColor:
     MyOrangeColor];
    [navCon.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    [controller presentModalViewController:navCon animated:YES];

}

+(void) showConfirmDialogInContoller: (UIViewController*) controller titled:(NSString*) title message:(NSString*) message onButtonClicked:(ResultCallback) onCallback
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:title
                                  message:message
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             if(onCallback) {
                                 onCallback([NSNumber numberWithInt:1]);
                             }
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 if(onCallback) {
                                     onCallback([NSNumber numberWithInt:0]);

                                 }
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [controller presentViewController:alert animated:YES completion:nil];
}

+(void) switchHUD:(JGProgressHUD*) HUD toProgress: (float) progress withMessage:(NSString*) msg andTitle:(NSString*) title
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        HUD.textLabel.text = msg;
        HUD.detailTextLabel.text = title;
        
        HUD.layoutChangeAnimationDuration = 0.3;
        HUD.indicatorView = [[JGProgressHUDPieIndicatorView alloc] init];
        HUD.progress = progress;
    });
    
}

+(void) switchHUD:(JGProgressHUD*) HUD withSuccess: (BOOL) success message:(NSString*) msg title: (NSString*) title andDismiss:(BOOL) dismiss
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        HUD.textLabel.text = msg;
        HUD.detailTextLabel.text = title;
        
        HUD.layoutChangeAnimationDuration = 0.3;
        HUD.indicatorView = success ? [[JGProgressHUDSuccessIndicatorView alloc] init] : [[JGProgressHUDErrorIndicatorView alloc] init];
    });
    
    if(dismiss) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [HUD dismiss];
        });
    }
    
}


@end