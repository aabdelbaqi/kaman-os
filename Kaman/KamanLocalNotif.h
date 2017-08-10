//
//  KamanLocalNotif.h
//  Kaman
//
//  Created by Moin' Victor on 22/12/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import <Realm/Realm.h>

@interface KamanLocalNotif : RLMObject
@property NSString  *notifId;
@property NSString  *kamanId;
@property NSString  *senderId;
@property NSString  *recepientId;
@property NSString  *target; // Host, Attendee
@property NSDate    *date;
@property NSString  *type; // ChatMessage,GroupMessage,Request,Inivite,Rated
@property NSString  *data;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<KamanLocalNotif>
RLM_ARRAY_TYPE(KamanLocalNotif)
