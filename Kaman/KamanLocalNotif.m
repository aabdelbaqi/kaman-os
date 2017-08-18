//
//  KamanLocalNotif.m
//  Kaman
//
//  Created by Moin' Victor on 22/12/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import "KamanLocalNotif.h"
#import "Utils.h"
@implementation KamanLocalNotif

// Specify default values for properties

+ (NSDictionary *)defaultPropertyValues
{
    return @{@"data" : @"",
             @"recepientId":[PFUser currentUser].objectId,
             @"date":[NSDate date]
             };
}

// Specify properties to ignore (Realm won't persist these)

//+ (NSArray *)ignoredProperties
//{
//    return @[];
//}

@end
