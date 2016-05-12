//
//  LocalCity.m
//  Kaman
//
//  Created by Moin' Victor on 14/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import "Offline.h"

@implementation LocalPlace

+ (NSString *)primaryKey {
    return @"name";
}

// Specify default values for properties

//+ (NSDictionary *)defaultPropertyValues
//{
//    return @{};
//}

// Specify properties to ignore (Realm won't persist these)

//+ (NSArray *)ignoredProperties
//{
//    return @[];
//}

@end
