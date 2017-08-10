//
//  Constants.h
//  Utah Appointments
//
//  Created by Moin' Victor on 26/10/2015.
//  Copyright © 2015 Onnox. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

#import "PFObject+KamanCat.h"

#define GET_CITIES_API_ENDPOINT @"https://maps.googleapis.com/maps/api/place/nearbysearch/json"

#define APP_STORE_LINK @"https://itunes.apple.com/us/app/kaman/id1059224877?ls=1&mt=8"

#define GOOGLE_MAPS_API_KEY @"AIzaSyCl2QcUIJJduPHtxrqupRJVVwyTincQsxA"
#define GOOGLE_PLACES_API_KEY @"AIzaSyCl2QcUIJJduPHtxrqupRJVVwyTincQsxA"

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

#define MailBlueColor UIColorFromRGB(0x1C80FF)
#define MyOrangeColor UIColorFromRGB(0xD44F3B)
#define MyOutgoingChatBg UIColorFromRGB(0xC3BEAF)
#define MyBrownColor [UIColor whiteColor]//UIColorFromRGB(0xE5E2D8)  //E5E1D9)
#define DesignersBrownColor UIColorFromRGB(0xE5E2D8)
#define MyGreyColor UIColorFromRGB(0xCACACA)
#define FacebookBlueColor UIColorFromRGB(0x3b5998)
#define WhatsappGreenColor UIColorFromRGB(0x2e8a06)
#define MenuBgBlack UIColorFromRGB(0x1A1A1A)
#define MyDarkGrayColor UIColorFromRGB(0x605E5B)
#define MyLightestGray UIColorFromRGB(0xededed)

#define DEFAULT_KAMAN_USER_MINIMUM_AGE 14
#define DEFAULT_KAMAN_USER_MAXIMUM_AGE 100
#define DEFAULT_DISCOVERY_PERIMETER_KM 75
#define DEFAULT_DISCOVERY_MINIMUM_AGE 18
#define DEFAULT_DISCOVERY_MAXIMUM_AGE 40

#define PUSH_TYPE_RATED @"Rated"
#define PUSH_TYPE_INVITED @"Invite"
#define PUSH_TYPE_INVITE_ACCEPTED @"InviteAccepted"
#define PUSH_TYPE_REQUESTED @"Request"
#define PUSH_TYPE_REQUEST_ACCEPTED @"RequestAccepted"
#define PUSH_TYPE_GROUP_MESSAGE @"GroupMessage"
#define PUSH_TYPE_CHAT_MESSAGE @"ChatMessage"


typedef void(^BoolResultCallback)(BOOL result);
typedef void(^ResultCallback)(id result);
typedef void(^ArrayPairResultCallback)(NSArray *pair1, NSArray *pair2);
typedef void(^ErrorCallback)(NSError* error);


@interface User : NSObject
@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *Name;
@property (nonatomic, strong) NSString *Phone;
@property (nonatomic, strong) NSString *TextingNo;
@property (nonatomic, strong) NSString *TwitterUserID;
@property (nonatomic, strong) NSString *FBUserID;
@property (nonatomic, strong) NSString *Email;
@property (nonatomic, strong) NSString *ActiveStatus;
@property (nonatomic, strong) NSDate *DateAdded;
@property (nonatomic, strong) NSMutableArray *appointments;
@end


@interface Appointment : NSObject
@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSNumber *Year;
@property (nonatomic, strong) NSNumber *Month;
@property (nonatomic, strong) NSNumber *Day;
@property (nonatomic, strong) NSNumber *TimeHr;
@property (nonatomic, strong) NSNumber *TimeMin;
@property (nonatomic, strong) NSString *Reason;
@property (nonatomic, strong) NSString *Status;
@property (nonatomic, strong) NSDate *DateAdded;
@end


#endif /* Constants_h */
