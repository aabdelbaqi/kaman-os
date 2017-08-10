//
//  PFUser+Kamaner.h
//  Kaman
//
//  Created by Moin' Victor on 09/12/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import <Parse/Parse.h>
#import "Utils.h"

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

-(void) hasBeenInvitedOrHasRequestedToAttendKaman:(PFObject*) kaman onCallBack: (BoolResultCallback) callback
                                                onError: (ErrorCallback) errorCallback;

-(void) updateUserColumn: (NSString*) column withValue: (id) value onCallBack: (ResultCallback) callback;

-(void) addUniqueEntry:(NSString*) object toArrayTableForKey:(NSString*) key;

-(void) inviteToKaman:(PFObject*) kaman onCallBack: (ResultCallback) callback
              onError: (ErrorCallback) errorCallback;

-(NSString*) userAgeAsStringOnNoAge :(NSString*) noAge;

-(void) requestToAttendKaman:(PFObject*) kaman onCallBack: (ResultCallback) callback
              onError: (ErrorCallback) errorCallback;

-(void) syncOnLoggedIn:(ResultCallback) thenDo;
@end
