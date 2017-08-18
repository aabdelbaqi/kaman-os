//
//  LocalCity.h
//  Kaman
//
//  Created by Moin' Victor on 14/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import <Realm/Realm.h>

@interface LocalPlace : RLMObject

@property NSString *name;
@property NSString *countryCode;
@property NSString *countryName;
@property double lat;
@property double lon;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<LocalCity>
RLM_ARRAY_TYPE(LocalPlace)
