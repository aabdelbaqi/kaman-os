//
//  AppDelegate.m
//  Kaman
//
//  Created by Moin' Victor on 11/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginButton.h>
#import "Utils.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "LocalNotif.h"
#import "SWRevealViewController.h"
#import "HomeViewController.h"
#import "NotificationsViewController.h"
#import "Session.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
NSInteger kamansViewed;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[UIBarButtonItem appearance] setTintColor:MyOrangeColor];
    
    // FB
    [FBSDKLoginButton class];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    // Parse
    // [Optional] Power your app with Local Datastore. For more info, go to
    // https://parse.com/docs/ios_guide#localdatastore/iOS
    //[Parse enableLocalDatastore];
    //[PFUser enableRevocableSessionInBackground];
    
    // Initialize Parse.
    [Parse setApplicationId:@"1vbNptEzFhOptvNm0cs0Gud8kVCFMg4LjyczEcXh"
                  clientKey:@"z7JGPZXO9QgB3OLvE4zHBX7Dz6JtGCSHupM7oFL7"];
    
    // [Optional] Track statistics around application opens.
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Parse push
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes  categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    // Google
    [GMSServices provideAPIKey:GOOGLE_MAPS_API_KEY];
    
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
   
    self.window.backgroundColor = MyBrownColor;
    
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
   // gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release
    
    NSDictionary *aPushNotification = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if(aPushNotification) {
        [self application:application didReceiveRemoteNotification:aPushNotification];
    }
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current Installation and save it to Parse
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    if([PFUser currentUser] != nil) {
        currentInstallation[@"user"] = [PFUser currentUser];
    } else {
        currentInstallation[@"user"] = [NSNull new];
    }
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if(error) {
            NSString *str = [NSString stringWithFormat: @"Error saving Device token: %@", error];
            NSLog(@"%@",str);
        } else {
            NSLog(@"Saved Device token: %@",deviceToken);
        }
    }];
    NSString *str = [NSString stringWithFormat:@"Device Token=%@",deviceToken];
    NSLog(@"%@", str);
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSString *str = [NSString stringWithFormat: @"Error: %@", err];
    NSLog(@"%@",str);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"Push: %@",userInfo);
    [self handlePush:userInfo];
    
}


-(void) handlePush:(NSDictionary *)kNotifInfo
{
    UIApplication *application = [UIApplication sharedApplication];
   
    NSString * type = [kNotifInfo objectForKey:@"type"];
    NSDictionary *aps = kNotifInfo[@"aps"];
    //NSNumber *badgeNumber = aps[@"badge"];
    
    NSString * message = [aps objectForKey:@"alert"];
    NSString * kamanObjId = [kNotifInfo objectForKey:@"kamanId"];
  
    [Utils fetchLocalNotifs:^(id result) {
        
    }];
    
    if (application.applicationState != UIApplicationStateActive) {
        return;
    }
    
    UIViewController * currentViewCintroller = [self topViewController];
    
    if([[currentViewCintroller class] isSubclassOfClass:[SWRevealViewController class]]) {
        UINavigationController * navCont = [(SWRevealViewController*)currentViewCintroller frontViewController];
        UIViewController * topCont = [navCont topViewController];
        
        if([[topCont class] isSubclassOfClass:
            [NotificationsViewController class]]) {
            
            NotificationsViewController * notifCont = topCont;
            [notifCont updateNotifBadgesThenReload:YES];
        } else if([[topCont class] isSubclassOfClass:
                   [HomeViewController class]]) {
            
            HomeViewController * homeCont = topCont;
            [homeCont updateNotifBadge];
        }

    }
    PFObject * kaman = [PFObject objectWithoutDataWithClassName:@"Kaman" objectId:kamanObjId];
    [kaman fetchInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (!error) {
          
            if ([type isEqualToString:PUSH_TYPE_INVITED]) {
                [Utils showInternalNotifIn:currentViewCintroller withTitle:[NSString stringWithFormat: @"%@ - %@",[object objectForKey:@"Name"],@"Invitation"] message:message withButtonTitle:nil onButtonClicked:^{
                    
                }];
            } else if ([type isEqualToString:PUSH_TYPE_REQUESTED]) {
                [Utils showInternalNotifIn:currentViewCintroller withTitle:[NSString stringWithFormat: @"%@ - %@",[object objectForKey:@"Name"],@"Request to attend"] message:message withButtonTitle:nil onButtonClicked:^{
                    
                }];
            } else if ([type isEqualToString:PUSH_TYPE_INVITE_ACCEPTED]) {
                [Utils showInternalNotifIn:currentViewCintroller withTitle:[NSString stringWithFormat: @"%@ - %@",[object objectForKey:@"Name"],@"Invite Accepted"] message:message withButtonTitle:nil onButtonClicked:^{
                    
                }];
            } else if ([type isEqualToString:PUSH_TYPE_REQUEST_ACCEPTED]) {
                [Utils showInternalNotifIn:currentViewCintroller withTitle:[NSString stringWithFormat: @"%@ - %@",[object objectForKey:@"Name"],@"Request Accepted"] message:message withButtonTitle:nil onButtonClicked:^{
                    
                }];
            } else if ([type isEqualToString:PUSH_TYPE_GROUP_MESSAGE]) {
                //NSRange range = [message rangeOfString:@"\n"];
                //NSString *newString = [message substringFromIndex:range.location];
                [Utils showInternalNotifIn:currentViewCintroller withTitle:[NSString stringWithFormat: @"%@ - %@",[object objectForKey:@"Name"],@"Group Message"] message:message withButtonTitle:nil onButtonClicked:^{
                    
                }];
            } else if ([type isEqualToString:PUSH_TYPE_CHAT_MESSAGE]) {
                //NSRange range = [message rangeOfString:@"\n"];
                //NSString *newString = [message substringFromIndex:range.location];
                [Utils showInternalNotifIn:currentViewCintroller withTitle:[NSString stringWithFormat: @"%@ - %@",[object objectForKey:@"Name"],@"Private Message"] message:message withButtonTitle:nil onButtonClicked:^{
                    
                }];
            } else if ([type isEqualToString:PUSH_TYPE_RATED]) {
                [Utils showInternalNotifIn:currentViewCintroller withTitle:[NSString stringWithFormat: @"%@ - %@",[object objectForKey:@"Name"],@"Ratings"] message:message withButtonTitle:nil onButtonClicked:^{
                }];
            } else {
                [PFPush handlePush:kNotifInfo];
            }
        }
    }];
    
    
}

- (UIViewController *)topViewController{
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [Utils sendGoogleAnalyticsTrackEventOfCategory:@"session_event" action:@"events_viewed" labeled:@"Events Viewed/Session" withValue:[NSNumber numberWithInteger:kamansViewed]];

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBSDKAppEvents activateApp];
    kamansViewed = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

@end
