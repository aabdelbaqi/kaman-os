//
//  Utils.h
//  Say-QR
//
//  Created by Moin' Victor on 28/10/2015.
//  Copyright © 2015 Onnox. All rights reserved.
//

#ifndef Utils_h
#define Utils_h

#import "Constants.h"
#import <AFNetworking/AFNetworking.h>
#import <OCMapper/OCMapper.h>
#import <JGProgressHUD/JGProgressHUD.h>
#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <QuartzCore/QuartzCore.h>
#import "Utils.h"
#import <CoreLocation/CoreLocation.h>
#import "Offline.h"
#import <Parse/Parse.h>
#import "TextFieldValidator.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <GoogleMaps/GoogleMaps.h>
#import "PFUser+Kamaner.h"
#import <TSMessages/TSMessageView.h>
#import "UIView+MGBadgeView.h"
#import <Google/Analytics.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "CWStatusBarNotification.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define TRIM(string) [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) // iPhone and       iPod touch style UI

#define IS_IPHONE_5_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_IPHONE_6_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0f)
#define IS_IPHONE_6P_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0f)
#define IS_IPHONE_4_AND_OLDER_IOS7 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height < 568.0f)

#define IS_IPHONE_5_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) == 568.0f)
#define IS_IPHONE_6_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) == 667.0f)
#define IS_IPHONE_6P_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) == 736.0f)
#define IS_IPHONE_4_AND_OLDER_IOS8 (IS_IPHONE && ([[UIScreen mainScreen] nativeBounds].size.height/[[UIScreen mainScreen] nativeScale]) < 568.0f)

#define IS_IPHONE_5 ( ( [ [ UIScreen mainScreen ] respondsToSelector: @selector( nativeBounds ) ] ) ? IS_IPHONE_5_IOS8 : IS_IPHONE_5_IOS7 )
#define IS_IPHONE_6 ( ( [ [ UIScreen mainScreen ] respondsToSelector: @selector( nativeBounds ) ] ) ? IS_IPHONE_6_IOS8 : IS_IPHONE_6_IOS7 )
#define IS_IPHONE_6P ( ( [ [ UIScreen mainScreen ] respondsToSelector: @selector( nativeBounds ) ] ) ? IS_IPHONE_6P_IOS8 : IS_IPHONE_6P_IOS7 )
#define IS_IPHONE_4_AND_OLDER ( ( [ [ UIScreen mainScreen ] respondsToSelector: @selector( nativeBounds ) ] ) ? IS_IPHONE_4_AND_OLDER_IOS8 : IS_IPHONE_4_AND_OLDER_IOS7 )

@interface NSString (emailValidation)
- (BOOL)isValidEmail;
@end

@interface Utils : NSObject

+ (void)runBlock:(void (^)())block;

+ (void)runAfterDelay:(CGFloat)delay block:(void (^)())block;

+ (BOOL)connected;

+(void) showMessageHUDInView:(UIView*) view withMessage:(NSString*) msg afterError:(BOOL) isError;

+(JGProgressHUD*) showProgressDialogInView: (UIView*) view withMessage :(NSString*) msg;

+(void) bottomBorderOnly: (UITextField*) textField;

+(NSDateFormatter*) getDateFormatter_MMM_D;

+(NSDateFormatter*) getTimeFormatter_H_MM_AMPM;

+(NSDateFormatter*) getDateFormatter_DD_MMMM_YYYY;

+(NSDate*) dateFromStringWithSec: (NSString*) YYYYY_MM_dd_HH_mm_ss;

+(NSString*) YYYYY_MM_dd_HH_mm_ss_FromDate: (NSDate*) date;

+(NSDate*) dateFromString: (NSString*) YYYYY_MM_dd_HH_mm;

+ (NSInteger)hoursBetween:(NSDate *)firstDate and:(NSDate *)secondDate;

+(NSString*) formatDate: (NSDate*) date;

+(NSDate*) localDate: (NSDate*) date;

+ (NSDate *)combineDate:(NSDate *)date withTime:(NSDate *)time;

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (NSString *) append:(id) first, ...;

+(void) styleButton: (UIButton*) button bgColor: (UIColor*) bgColor highlightColor: (UIColor*) highlightColor;

+(void) styleButton: (UIButton*) button bgColor: (UIColor*) bgColor highlightColor: (UIColor*) highlightColor radius: (NSInteger) radii;

+(void) styleTextView: (UITextView*) textView;

+(void) postfixImageNamed: (NSString*) imageName toTextField: (UITextField*) textfield;

+(void) prefixImageNamed: (NSString*) imageName toTextField: (UITextField*) textfield;

+(void) setUIView: (UIView*) uiView backgroundColor: (UIColor*) color andRoundedByRadius:(NSInteger) radius withBorderColor: (UIColor*) borderColor;

+(void) getPlacesAroundLatitude: (double)lat longitude: (double)lon onCallback: (ResultCallback) resultCallback onError: (ErrorCallback) errorCallback;

+(void) locallyStoreLocalPlace: (NSString*) area fromCountry: (NSString*) country andCountryCode: (NSString*) cCode withLocationLat: (double) latitude andLocationLon: (double) longitude onSuccess: (ResultCallback) callback;

+(void) parseSmartStoreKamanArea: (NSString*) area fromCountry: (NSString*) country andCountryCode: (NSString*) cCode withLocationLat: (double) lat locationLon: (double) lon onSuccess:(ResultCallback) callback onError:(ErrorCallback) errorCallback;

+(void) setTitle:(NSString *)title withColor: (UIColor*) titleColor andSubTitle: (NSString*) subTitle withColor: (UIColor*) subtitleColor onNavigationController: (UIViewController*) controller;

+(void) sendPushFor:(NSString*) type toUser: (PFUser*) user withMessage:(NSString*) message ForKaman: (PFObject*) kaman;

+(void) sendPushFor:(NSString*) type toChannel: (NSString*) channelName withMessage:(NSString*) message ForKaman: (PFObject*) kaman targetUsers:(NSArray*) users;

+(void) sendPushFor:(NSString*) type toQuery: (PFQuery*) pushQuery withMessage:(NSString*) message ForKaman: (PFObject*) kaman targetUsers:(NSArray*) users
;

+(void)showInternalNotifIn:(UIViewController*) controller withTitle:(NSString*) title message:(NSString*) message
           withButtonTitle: (NSString*) buttonTitle onButtonClicked:(void (^__strong)())buttonCallback;

+(void) updateApplicationBadge;

+(void) fetchLocalNotifs:(ResultCallback) whenDone;

+(void) addLocalNotifWithID:(NSString*)_id ofType:(NSString*) type fromSender :(NSString*) senderObjId forKaman: (NSString*) kamanObjId hostedBy:(NSString*) kamanHostId withAlert:(NSString*) alert dated:(NSDate*) date;

+(void) sendGoogleAnalyticsTrackEventOfCategory:(NSString*) category
                                         action:(NSString*) action labeled:(NSString*)label withValue: (NSNumber*) value;

+(NSInteger) updateNotifBadgeFor:(NSString*) query toView:(UIView*) view position: (MGBadgePosition) position;

+(void) goToTerms:(UIViewController*) controller skipToPrivacy:(BOOL) skipToPrivacy;

+(NSInteger) deleteNotifsWithQuery:(NSString*) query;

+(void) fetchFBFriends;

+(void)fetchFBProfile;

+(void) fetchFBForLogedInUser;

+(void) showConfirmDialogInContoller: (UIViewController*) controller titled:(NSString*) title message:(NSString*) message onButtonClicked:(ResultCallback) onCallback;

+(void) switchHUD:(JGProgressHUD*) HUD toProgress: (float) progress withMessage:(NSString*) msg andTitle:(NSString*) title;

+(void) switchHUD:(JGProgressHUD*) HUD withSuccess: (BOOL) success message:(NSString*) msg title: (NSString*) title andDismiss:(BOOL) dismiss;

+(void) invitesAndRequestsForKaman:(PFObject*) kaman onSuccess:(ArrayPairResultCallback) callback onError:(ErrorCallback) errorCallback;

+(void) showStatusNotificationWithMessage:(NSString*) msg isError:(BOOL) isError;

@end


#endif /* Utils_h */
