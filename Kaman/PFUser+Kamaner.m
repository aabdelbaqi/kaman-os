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
        [Utils updateCurrentPFUserColumn:@"ArchivedKamans" withValue:[NSArray new] onCallBack:nil];
    }
    
    if(![PFUser currentUser][@"InvitedKamans"]) {
        [Utils updateCurrentPFUserColumn:@"InvitedKamans" withValue:[NSArray new] onCallBack:nil];
    }
    
    if(![PFUser currentUser][@"LikedKamans"]) {
        [Utils updateCurrentPFUserColumn:@"LikedKamans" withValue:[NSArray new] onCallBack:nil];
    }
    
    if(![PFUser currentUser][@"NotifyRatings"]) {
        [Utils updateCurrentPFUserColumn:@"NotifyRatings" withValue:[NSNumber numberWithBool:YES] onCallBack:nil];
    }
    
    if(![PFUser currentUser][@"Visibility"]) {
        [Utils updateCurrentPFUserColumn:@"Visibility" withValue:[NSNumber numberWithBool:YES] onCallBack:nil];
    }
    
    if(![PFUser currentUser][@"NotifyRequests"]) {
        [Utils updateCurrentPFUserColumn:@"NotifyRequests" withValue:[NSNumber numberWithBool:YES] onCallBack:nil];
    }
    
    if(![PFUser currentUser][@"NotifyMessages"]) {
        [Utils updateCurrentPFUserColumn:@"NotifyMessages" withValue:[NSNumber numberWithBool:YES] onCallBack:nil];
    }
    
    if(![PFUser currentUser][@"NotifyInvites"]) {
        [Utils updateCurrentPFUserColumn:@"NotifyInvites" withValue:[NSNumber numberWithBool:YES] onCallBack:nil];
    }
    
    if(![PFUser currentUser][@"DiscoverFriendsOnly"]) {
        [Utils updateCurrentPFUserColumn:@"DiscoverFriendsOnly" withValue:[NSNumber numberWithBool:NO] onCallBack:nil];
    }
    
    if(![PFUser currentUser][@"DiscoveryPerimeter"]) {
         [Utils updateCurrentPFUserColumn:@"DiscoveryPerimeter" withValue:[NSNumber numberWithInt:DEFAULT_DISCOVERY_PERIMETER_KM] onCallBack:nil];
    }
    
    if(![PFUser currentUser][@"DiscoveryAgeMin"]) {
        [Utils updateCurrentPFUserColumn:@"DiscoveryAgeMin" withValue:[NSNumber numberWithInt:DEFAULT_DISCOVERY_MINIMUM_AGE] onCallBack:nil];
    }

    if(![PFUser currentUser][@"DiscoveryAgeMax"]) {
        [Utils updateCurrentPFUserColumn:@"DiscoveryAgeMax" withValue:[NSNumber numberWithInt:DEFAULT_DISCOVERY_MAXIMUM_AGE] onCallBack:nil];
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

@end
