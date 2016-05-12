//
//  PFUser+Kamaner.h
//  Kaman
//
//  Created by Moin' Victor on 09/12/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import <Parse/Parse.h>

@interface PFUser (Kamaner)

-(NSString*) displayName;
-(NSString*) profileImageURL;
-(BOOL) isVisibileToOtherKamans;
-(NSNumber*) discoveryAgeMin;
-(NSNumber*) discoveryAgeMax;
-(NSNumber*) discoveryPerimeter;
-(BOOL) discoveredByFriendsOnly;

-(BOOL) notifyRequests;

-(BOOL) notifyInvites;

-(BOOL) notifyMessages;

-(BOOL) notifyRatings;

+(void) setUserDefaultsForCurrentUser;

-(BOOL) isFacebookFriendsWith:(PFUser*) suspect;
@end
