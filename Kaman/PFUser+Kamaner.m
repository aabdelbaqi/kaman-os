//
//  PFUser+Kamaner.m
//  Kaman
//
//  Created by Moin' Victor on 09/12/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import "PFUser+Kamaner.h"
#import "Utils.h"

@implementation PFUser (Kamaner)


+(void) setUserDefaultsForCurrentUser
{
    
    if(![PFUser currentUser][@"ArchivedKamans"]) {
        [[PFUser currentUser] updateUserColumn:@"ArchivedKamans" withValue:[NSArray new] onCallBack:nil];
    }
    
    if(![PFUser currentUser][@"InvitedKamans"]) {
        [[PFUser currentUser] updateUserColumn:@"InvitedKamans" withValue:[NSArray new] onCallBack:nil];
    }
    
    if(![PFUser currentUser][@"LikedKamans"]) {
        [[PFUser currentUser] updateUserColumn:@"LikedKamans" withValue:[NSArray new] onCallBack:nil];
    }
    
    if(![PFUser currentUser][@"NotifyRatings"]) {
        [[PFUser currentUser] updateUserColumn:@"NotifyRatings" withValue:[NSNumber numberWithBool:YES] onCallBack:nil];
    }
    
    if(![PFUser currentUser][@"Visibility"]) {
        [[PFUser currentUser] updateUserColumn:@"Visibility" withValue:[NSNumber numberWithBool:YES] onCallBack:nil];
    }
    
    if(![PFUser currentUser][@"NotifyRequests"]) {
        [[PFUser currentUser] updateUserColumn:@"NotifyRequests" withValue:[NSNumber numberWithBool:YES] onCallBack:nil];
    }
    
    if(![PFUser currentUser][@"NotifyMessages"]) {
        [[PFUser currentUser] updateUserColumn:@"NotifyMessages" withValue:[NSNumber numberWithBool:YES] onCallBack:nil];
    }
    
    if(![PFUser currentUser][@"NotifyInvites"]) {
        [[PFUser currentUser] updateUserColumn:@"NotifyInvites" withValue:[NSNumber numberWithBool:YES] onCallBack:nil];
    }
    
    if(![PFUser currentUser][@"DiscoverFriendsOnly"]) {
        [[PFUser currentUser] updateUserColumn:@"DiscoverFriendsOnly" withValue:[NSNumber numberWithBool:NO] onCallBack:nil];
    }
    
    if(![PFUser currentUser][@"DiscoveryPerimeter"]) {
         [[PFUser currentUser] updateUserColumn:@"DiscoveryPerimeter" withValue:[NSNumber numberWithInt:DEFAULT_DISCOVERY_PERIMETER_KM] onCallBack:nil];
    }
    
    if(![PFUser currentUser][@"DiscoveryAgeMin"]) {
        [[PFUser currentUser] updateUserColumn:@"DiscoveryAgeMin" withValue:[NSNumber numberWithInt:DEFAULT_DISCOVERY_MINIMUM_AGE] onCallBack:nil];
    }

    if(![PFUser currentUser][@"DiscoveryAgeMax"]) {
        [[PFUser currentUser] updateUserColumn:@"DiscoveryAgeMax" withValue:[NSNumber numberWithInt:DEFAULT_DISCOVERY_MAXIMUM_AGE] onCallBack:nil];
    }
    
}

-(NSString *)displayName
{
    NSString *name = [self objectForKey:@"CustomProfileName"];
    if([name isEqual:[NSNull null]] || name == nil) {
        name = [self objectForKey:@"SocialProfileName"];
    }
    
    if([name isEqual:[NSNull null]] || name == nil) {
        name = @"<No Name Set>";
    }

    return name;
}


-(NSNumber*) discoveryPerimeter
{
    NSNumber *number = [self objectForKey: @"DiscoveryPerimeter"];
    if(!number) {
        number = [NSNumber numberWithInt:DEFAULT_DISCOVERY_PERIMETER_KM];
    }
    return number;
}

-(NSNumber*) discoveryAgeMin
{
    NSNumber *number = [self objectForKey: @"DiscoveryAgeMin"];
    if(!number) {
        number = [NSNumber numberWithInt:DEFAULT_DISCOVERY_MINIMUM_AGE];
    }
    return number;
}

-(BOOL) discoveredByFriendsOnly
{
    NSNumber *visibilityNSNumber = [self objectForKey: @"DiscoverFriendsOnly"];
    bool visibilityBoolean = [visibilityNSNumber boolValue];
    return visibilityBoolean;
}



-(NSNumber*) discoveryAgeMax
{
    NSNumber *number = [self objectForKey: @"DiscoveryAgeMax"];
    if(!number) {
        number = [NSNumber numberWithInt:DEFAULT_KAMAN_USER_MAXIMUM_AGE];
    }
    return number;
}

-(BOOL) notifyRequests
{
    NSNumber *visibilityNSNumber = [self objectForKey: @"NotifyRequests"];
    bool _boolean = [visibilityNSNumber boolValue];
    return _boolean;
}

-(BOOL) notifyInvites
{
    NSNumber *visibilityNSNumber = [self objectForKey: @"NotifyInvites"];
    bool _boolean = [visibilityNSNumber boolValue];
    return _boolean;
}

-(BOOL) notifyMessages
{
    NSNumber *visibilityNSNumber = [self objectForKey: @"NotifyMessages"];
    bool _boolean = [visibilityNSNumber boolValue];
    return _boolean;
}

-(BOOL) notifyRatings
{
    NSNumber *visibilityNSNumber = [self objectForKey: @"NotifyRatings"];
    bool _boolean = [visibilityNSNumber boolValue];
    return _boolean;
}

-(BOOL) isVisibileToOtherKamans
{
    NSNumber *visibilityNSNumber = [self objectForKey: @"Visibility"];
    bool visibilityBoolean = [visibilityNSNumber boolValue];
    return visibilityBoolean;
}

-(NSString*) profileImageURL
{
    NSString *url = [self objectForKey:@"CustomProfileImage"];
    if(!url) {
        url = [self objectForKey:@"SocialProfileImage"];
    }
    return url;
}

-(BOOL)isFacebookFriendsWith:(PFUser *)suspect
{
    NSString * fbId = [suspect objectForKey:@"FBUserID"];
    NSArray * friendsIds = [self objectForKey:@"FBFriendsUserIDs"];
    return [friendsIds containsObject:fbId];
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[PFUser class]]) {
        PFUser * other = object;
        return self.objectId == other.objectId;
    }
    else if (![object isKindOfClass:self.class]) {
        return NO;
    }
    return [super isEqual:object];
}

-(void) inviteToKaman:(PFObject*) kaman onCallBack: (ResultCallback) callback
              onError: (ErrorCallback) errorCallback
{
    
    PFRelation *relation = [kaman relationForKey:@"Invitations"];
    
    PFObject *kamanInvite = [PFObject objectWithClassName:@"KamanInvite"];
    [kamanInvite setObject:self forKey:@"InvitedUser"];
    [kamanInvite setObject:kaman forKey:@"Kaman"];
    [kamanInvite setObject:[NSNumber numberWithBool:NO] forKey:@"Accepted"];
    [kamanInvite saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        
        if (!error) {
            [relation addObject:kamanInvite];
            [kaman saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(!error) {
                //    [self addUniqueEntry:kaman.objectId toArrayTableForKey:@"InvitedKamans"];
                } else {
                    NSLog(@"Error making Kaman Invite: %@",error.localizedDescription);
                    [kaman saveEventually:^(BOOL succeeded, NSError * _Nullable error) {
                        if(succeeded) {
                           // [self addUniqueEntry:kaman.objectId toArrayTableForKey:@"InvitedKamans"];
                        }
                    }];
                }
                if(callback) {
                    callback(kamanInvite);
                }
            }];
            
        } else {
            if(errorCallback) {
                errorCallback(error);
            }
        }
    }];

}

-(void) addUniqueEntry:(NSString*) object toArrayTableForKey:(NSString*) key
{
    [self addUniqueObject:object forKey:key];
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error) {
            [self saveEventually];
            NSLog(@"Error saving user liked kaman: %@",error.localizedDescription);
        }
    }];
}

-(void) hasBeenInvitedOrHasRequestedToAttendKaman:(PFObject*) kaman onCallBack: (BoolResultCallback) callback
onError: (ErrorCallback) errorCallback {
    PFRelation * invitesRelation = [kaman relationForKey:@"Invitations"];
    PFQuery * invitesQuery = [invitesRelation query];
    [invitesQuery whereKey:@"InvitedUser" equalTo:self];
    
    PFRelation * requestsRelation = [kaman relationForKey:@"Requests"];
    PFQuery * requestsQuery = [requestsRelation query];
    [requestsQuery whereKey:@"RequestingUser" equalTo:self];
    
    
    dispatch_group_t invitesRequestsGroup = dispatch_group_create();
    
    __block NSError * error = nil;
    __block int requestedCount = 0, invitedCount = 0;
    
    // Load invites
    dispatch_group_enter(invitesRequestsGroup);
    [invitesQuery countObjectsInBackgroundWithBlock:^(int invitesCount, NSError * _Nullable err) {
        if(!err) {
            invitedCount = invitesCount;
        } else {
            error = err;
        }
        dispatch_group_leave(invitesRequestsGroup);
    }];
    
    // Load kaman requests
    dispatch_group_enter(invitesRequestsGroup);
    [requestsQuery countObjectsInBackgroundWithBlock:^(int requestsCount, NSError * _Nullable err) {
        if(!err) {
             requestedCount = requestsCount;
        } else {
            error = err;
        }
        dispatch_group_leave(invitesRequestsGroup);
    }];
    
    
    dispatch_group_notify(invitesRequestsGroup,dispatch_get_main_queue(),^{
        // Won't get here until everything has finished
        if(error) {
            errorCallback(error);
        } else {
            int number = requestedCount + invitedCount;
            if (callback) {
                callback(number > 0);
            }
            
        }
    });
    
}


-(void) updateUserColumn: (NSString*) column withValue: (id) value onCallBack: (ResultCallback) callback
{
    if(value) {
        [self setObject: value forKey:column];
        
    }
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
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


-(NSString*) userAgeAsStringOnNoAge :(NSString*) noAge
{
    NSDate *dob = [self objectForKey:@"DateOfBirth"];
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

-(void)requestToAttendKaman:(PFObject *)kaman onCallBack:(ResultCallback)callback onError:(ErrorCallback)errorCallback
{
    PFUser *host = [kaman objectForKey:@"Host"];
    PFRelation *relation = [kaman relationForKey:@"Requests"];
    
    PFObject *kamanRequest = [PFObject objectWithClassName:@"KamanRequest"];
    [kamanRequest setObject:self forKey:@"RequestingUser"];
    [kamanRequest setObject:kaman forKey:@"Kaman"];
    [kamanRequest setObject:[NSNumber numberWithBool:NO] forKey:@"Accepted"];
    [kamanRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        
        if (!error) {
            [relation addObject:kamanRequest];
            
            [kaman saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(!error) {
                    [self addUniqueEntry:kaman.objectId toArrayTableForKey:@"LikedKamans"];
                } else {
                    NSLog(@"Error making Kaman Request: %@",error.localizedDescription);
                    [kaman saveEventually];
                    [self addUniqueEntry:kaman.objectId toArrayTableForKey:@"LikedKamans"];
                }
                
            }];
            
            if(callback) {
                callback(kamanRequest);
            }
        } else {
            if(errorCallback) {
                errorCallback(error);
            }
        }
        
        
    }];
}

-(void) syncOnLoggedIn:(ResultCallback) thenDo
{
    dispatch_group_t invitesRequestsGroup = dispatch_group_create();
    
    
    PFUser * user = self;
    // sync Requests
    dispatch_group_enter(invitesRequestsGroup);
    
    PFQuery * query = [PFQuery queryWithClassName:@"KamanRequest"];
    [query whereKey:@"RequestingUser" equalTo:user];
    [query includeKey:@"Kaman"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error) {
            for (PFObject *obj in objects) {
                PFObject * kaman = [obj objectForKey:@"Kaman"];
             //   NSLog(@"Liked Kaman: %@",kaman.objectId);
                [user addUniqueObjectsFromArray:[NSArray arrayWithObject:kaman.objectId] forKey:@"LikedKamans"];
                NSNumber *acceptedNSNumber = [obj objectForKey: @"Accepted"];
                bool _boolean = [acceptedNSNumber boolValue];
                if(_boolean) {
                    [user addUniqueObjectsFromArray:[NSArray arrayWithObject:kaman.objectId] forKey:@"KamansAttended"];
                    
                }
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if(error) {
                        [user saveEventually];
                        NSLog(@"Error saving user liked kaman: %@",error.localizedDescription);
                    }
                }];
                
            }
        } else {
            NSLog(@"Error finding user liked kamans: %@",error.localizedDescription);
        }
          dispatch_group_leave(invitesRequestsGroup);
    }];
    
    // sync Invites
    dispatch_group_enter(invitesRequestsGroup);
    
    PFQuery * query2 = [PFQuery queryWithClassName:@"KamanInvite"];
    [query2 whereKey:@"InvitedUser" equalTo:user];
    [query2 includeKey:@"Kaman"];
    [query2 findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error) {
            for (PFObject *obj in objects) {
                PFObject * kaman = [obj objectForKey:@"Kaman"];
                //NSLog(@"Invited Kaman: %@",kaman.objectId);
                [user addUniqueObjectsFromArray:[NSArray arrayWithObject:kaman.objectId] forKey:@"InvitedKamans"];
                NSNumber *acceptedNSNumber = [obj objectForKey: @"Accepted"];
                bool _boolean = [acceptedNSNumber boolValue];
                if(_boolean) {
                    [user addUniqueObjectsFromArray:[NSArray arrayWithObject:kaman.objectId] forKey:@"KamansAttended"];
                    
                }
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if(error) {
                        [user saveEventually];
                        NSLog(@"Error saving user invited kaman: %@",error.localizedDescription);
                    }
                }];
                
            }
        }  else {
            NSLog(@"Error finding user invited kaman: %@",error.localizedDescription);
        }
          dispatch_group_leave(invitesRequestsGroup);
        
    }];
    
    // sync Hosted Kamans
    dispatch_group_enter(invitesRequestsGroup);
    
    PFQuery * query3 = [PFQuery queryWithClassName:@"Kaman"];
    [query3 whereKey:@"Host" equalTo:user];
    [query3 findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error) {
            for (PFObject *kaman in objects) {
               // NSLog(@"User Hosted Kaman: %@",kaman.objectId);
                [user addUniqueObjectsFromArray:[NSArray arrayWithObject:kaman.objectId] forKey:@"KamansHosted"];
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if(error) {
                        [user saveEventually];
                        NSLog(@"Error saving user invited kaman: %@",error.localizedDescription);
                    }
                }];
                
            }
        }  else {
            NSLog(@"Error finding user invited kaman: %@",error.localizedDescription);
        }
          dispatch_group_leave(invitesRequestsGroup);
        
    }];
    
    dispatch_group_notify(invitesRequestsGroup,dispatch_get_main_queue(),^{
        // Won't get here until everything has finished
        if(thenDo) {
            thenDo(nil);
        }
    });

}

@end
