//
//  HomeViewController.m
//  Kaman
//
//  Created by Moin' Victor on 11/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import "HomeViewController.h"
#import "SWRevealViewController.h"
#import "Utils.h"
#import "KamansTableEmptyView.h"
#import "BasicKamansTableViewCell.h"
#import "PhotosKamanTableViewCell.h"
#import "KamanActionButtonsView.h"
#import "DetailKamanTableViewCell.h"
#import "ParallaxHeaderView.h"
#import "UIImage+ImageEffects.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "Session.h"
#import "KamanLocalNotif.h"
#import "ParallaxHeaderView.h"

@interface HomeViewController ()
@property BOOL devMode;
@end

LocalPlace *currentLocality;
FLAnimatedImage *animatedImage;
NSTimer *search_kamans_timer, *update_notifs_timer;
NSString * statusText;

ParallaxHeaderView *profileHeaderView, *menuHeaderView;

@implementation HomeViewController



- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.kamans = [NSMutableArray new];
    self.showButtons = YES;
    statusText = @"There are no more Kamans around you";
    
    self.headerPannable = YES;
    
    UIImage *img = [UIImage imageNamed:@"kaman-logo"];

    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [imgView setImage:img];
    // setContent mode aspect fit
    [imgView setContentMode:UIViewContentModeScaleAspectFit];
    self.navigationItem.titleView = imgView;
    
    // Set the side bar button action. When it's tapped, it'll show up the sidebar.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    _sidebarButton.tintColor = MyOrangeColor;
    
    self.view.backgroundColor = MyBrownColor;
    self.tableView.backgroundColor = MyBrownColor;
    // Set the gesture
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    [self requestLocationAuthorization];
    
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *lastLocalityName = [defaults stringForKey:@"last_locality_name"];
    NSString *lastLocalityCCode = [defaults stringForKey:@"last_locality_country_code"];
    
    if(lastLocalityName) {
        NSString * query = [NSString stringWithFormat:  @"name = '%@' AND countryCode = '%@'", lastLocalityName, lastLocalityCCode];
        RLMResults *areas = [LocalPlace objectsWhere:query];
        if([areas count] > 0) {
            currentLocality = [areas objectAtIndex:0];
            [self searchKamans];
        }
    }
}


-(void) updateNotifBadge
{
    
    RLMResults<KamanLocalNotif *> *notifs = [KamanLocalNotif allObjects]; // retrieves all LocalNotifs from the default Realm
    UIView * view = [self.notifbarButton valueForKey:@"view"];

    view.badgeView.badgeValue = [notifs count];
    view.badgeView.badgeColor = DesignersBrownColor;
    view.badgeView.textColor = [UIColor blackColor];
    view.badgeView.position = MGBadgePositionKamanFix;
    [view.badgeView setOutlineWidth:2.0];
    [view.badgeView setOutlineColor:MyGreyColor];
    view.badgeView.horizontalOffset = 5.0;
    view.badgeView.verticalOffset = 5.0;
    
}

-(void) sendGoogleAnalyticsTrackScreen
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Home screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self sendGoogleAnalyticsTrackScreen];
    
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
  
    if(![FBSDKAccessToken currentAccessToken] ) {
        [PFUser logOutInBackground];
        [Utils deleteNotifsWithQuery:nil];
     
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"lastLoadDate"];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"lastDate"];
        
        [[self presentingViewController] dismissViewControllerAnimated:NO completion:nil];
        return;
    }
    
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        if(config) {
            NSNumber *devModeNSNumber = [config objectForKey: @"DevMode"];
            _devMode = [devModeNSNumber boolValue];

        }
    }];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if(currentInstallation) {
        currentInstallation[@"user"] = [PFUser currentUser];
        [currentInstallation saveInBackground];
    }
    search_kamans_timer = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(searchKamans) userInfo:nil repeats:YES];
    
    update_notifs_timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(updateNotifBadge) userInfo:nil repeats:YES];
    
    [Utils fetchLocalNotifs:^(id result) {
        [self updateNotifBadge];
    }];
    [self updateNotifBadge];
    
    NSURL *url1 = [[NSBundle mainBundle] URLForResource:/*@"Animate"*/ @"Kaman_animation2" withExtension:@"gif"];
    NSData *animationData = [NSData dataWithContentsOfURL:url1];
    animatedImage= [FLAnimatedImage animatedImageWithGIFData:animationData];
    
    if(currentLocality && [self.kamans count] == 0) {
        [self searchKamans];
    }
    [self.tableView reloadData];
    
    [PFUser setUserDefaultsForCurrentUser];
    
}

- (void)viewWillDisappear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewWillDisappear:animated];
    [search_kamans_timer invalidate];
    [update_notifs_timer invalidate];
}

-(IBAction)hostKaman:(id)sender
{
    [self performSegueWithIdentifier:@"go_host_kaman" sender:nil];
}

-(IBAction)inviteFriends:(id)sender
{
    [self performSegueWithIdentifier:@"go_invite_friends" sender:nil];
}



-(void) onDecline
{
    PFObject *kaman = [self.kamans firstObject];
    
   // [[PFUser currentUser] addUniqueObject:kaman.objectId forKey:@"ArchivedKamans"];
   // [[PFUser currentUser] saveInBackground];
    
    [self.kamans removeObjectAtIndex:0];
    [self resetCounters];
    
    [self.tableView reloadData];
    
    if([self.kamans count] == 0) {
        [self searchKamans];
    }
    
    kamansViewed += 1;
}

-(void) doRequestParty:(PFObject*) kaman
{
    PFUser *user = [PFUser currentUser];
   // PFObject *kaman = [self.kamans firstObject];
    if(!kaman) {
        return;
    }
    PFUser *host = [kaman objectForKey:@"Host"];
    [user requestToAttendKaman:kaman onCallBack:^(id result) {
        if([host notifyRequests]) {
            [Utils sendPushFor:PUSH_TYPE_REQUESTED toUser:host withMessage:[NSString stringWithFormat: @"Someone wants to attend '%@'.",[kaman objectForKey:@"Name"]] ForKaman:kaman];
        }
    } onError:^(NSError *error) {
         NSLog(@"Error %@",error);
        [Utils showStatusNotificationWithMessage:[NSString stringWithFormat:@"Error: %@", error.localizedDescription] isError:YES];
    }];
    
}

-(void)onAccept
{

    PFUser *user = [PFUser currentUser];
    PFObject *kaman = [self.kamans firstObject];
    
    [user hasBeenInvitedOrHasRequestedToAttendKaman:kaman onCallBack:^(BOOL result) {
        if (result) {
              NSLog(@"you have already been invited or requested to attaned %@",[kaman objectForKey:@"Name"]);
            [Utils showStatusNotificationWithMessage:@"Already requested or been invited to attend this Kaman" isError:NO];
        }else {
            NSLog(@"you have NOT been invited or requested to attaned %@",[kaman objectForKey:@"Name"]);
             [self doRequestParty:kaman];
        }
        
    } onError:^(NSError *error) {
        NSLog(@"Error %@",error);
         [Utils showStatusNotificationWithMessage:[NSString stringWithFormat:@"Error: %@", error.localizedDescription] isError:YES];
    }];

    [self.kamans removeObjectAtIndex:0];
    [self resetCounters];
    [self.tableView reloadData];
    
    if([self.kamans count] == 0) {
        [self searchKamans];
    }
    kamansViewed += 1;
}

-(void) resetCounters
{
    self.maleAttendees =  [NSMutableDictionary new];
    self.femaleAttendees = [NSMutableDictionary new];
    self.attendees = [NSMutableArray new];
    self.kamanImages = [NSMutableArray new];
    self.kamanImageUrls = [NSMutableArray new];
    self.tableSize = TABLE_SIZE_BASIC;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if ([self.kamans count] > 0) {
        
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.tableFooterView = [UIView new];
        return 1;
        
    } else {
        
        NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"KamansTableEmptyView"
                                                          owner:self
                                                        options:nil];
        int startIndex;
#ifdef __IPHONE_2_1
        startIndex = 0;
#else
        startIndex = 1;
#endif
        KamansTableEmptyView* myView = [ nibViews objectAtIndex: startIndex];
        myView.backgroundColor = MyBrownColor;
        
        [myView.animImageView setAnimatedImage:animatedImage];
        [myView.animImageView startAnimating];
        
        [myView.hostButton addTarget:self action:@selector(hostKaman:) forControlEvents:UIControlEventTouchUpInside];
        [myView.inviteButton addTarget:self action:@selector(inviteFriends:) forControlEvents:UIControlEventTouchUpInside];
        [Utils styleButton:myView.hostButton bgColor:MyOrangeColor highlightColor:MyGreyColor];
        [Utils styleButton:myView.inviteButton bgColor:MyOrangeColor highlightColor:MyGreyColor];
        
       // [myView setBounds:self.tableView.bounds];
       // [myView setFrame: self.tableView.frame];
       
        self.tableView.backgroundView = myView;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    
    return 0;
}


-(IBAction)searchKamans
{
    [[PFUser currentUser] syncOnLoggedIn:^(id result) {
        [self doActuallySearchKamans];
    }];
}

-(void) doActuallySearchKamans
{

    [self updateNotifBadge];
    
    if([self.kamans count] > 0) {
        return;
    }
    
    
    PFUser *user = [PFUser currentUser];
    
    NSNumber *distanceNSNumber = [[PFUser currentUser] objectForKey: @"DiscoveryPerimeter"];
    if(!distanceNSNumber) {
        distanceNSNumber = [NSNumber numberWithInt:DEFAULT_DISCOVERY_PERIMETER_KM];
    }
    statusText = @"Searching Kamans around you...";
    
    PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLatitude:currentLocality.lat longitude:currentLocality.lon];
    // Create a query for places
    PFQuery *query = [PFQuery queryWithClassName:@"KamanArea"];
    // Interested in locations near user.
   
    //[query whereKey:@"CountryCode" equalTo:currentLocality.countryCode];
    if(self.devMode == false) {
        [query whereKey:@"LatLong" nearGeoPoint:userGeoPoint withinKilometers:distanceNSNumber.intValue];
    }
    // Final list of objects
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        
        if (!error) {
            PFQuery *filterInvitedQuery = [PFQuery queryWithClassName:@"KamanInvite"];
            [filterInvitedQuery whereKey:@"InvitedUser" equalTo:user];
            
            PFQuery *query = [PFQuery queryWithClassName:@"Kaman"];
            [query whereKey:@"Host" notEqualTo:user];
            [query whereKey:@"DateTime" greaterThan:[NSDate date]];
            [query whereKey:@"objectId" notContainedIn:[user objectForKey:@"ArchivedKamans"]];
            [query whereKey:@"objectId" notContainedIn:[user objectForKey:@"LikedKamans"]];
            [query whereKey:@"objectId" notContainedIn:[user objectForKey:@"InvitedKamans"]];
            // not archived by the host
            [query whereKey:@"Archived" notEqualTo:[NSNumber numberWithBool:YES]];
            [query includeKey:@"Area"];
            [query includeKey:@"Host"];
            // Interested in locations near user.
            [query whereKey:@"Area" containedIn:objects];
            [query orderByAscending:@"DateTime"];
            // Limit what could be a lot of points.
            [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                if(!error) {
                    if([objects count] > 0) {
                         [self.kamans removeAllObjects];
                        for (PFObject * kmn in objects) {
                            PFUser * host = [kmn objectForKey:@"Host"];
                            NSArray * invited = [[PFUser currentUser] objectForKey:@"InvitedKamans"];
                            NSArray * liked = [[PFUser currentUser] objectForKey:@"LikedKamans"];
                            if(![invited containsObject:kmn.objectId] && ![liked containsObject:kmn.objectId]) // only if kaman is not alreay liked by user and user not invited to already
                        
                                // if user only wants posts from Facebook friends, we filter the rest out
                                if([user discoveredByFriendsOnly]) {
                                    if ([user isFacebookFriendsWith:host]) {
                                        [self.kamans addObject:kmn];
                                    }
                                } else {
                                    [self.kamans addObject:kmn];
                                }
                            
                        }
                         statusText = [NSString stringWithFormat: @"There are %lu Kamans around you",(unsigned long)[self.kamans count] ];
                        
                        self.kamanImages = [NSMutableArray new];
                        self.tableSize = TABLE_SIZE_BASIC;
                    } else {
                        statusText =@"There are no more Kamans around you";
                    }
                } else {
                    // TODO handle error
                    statusText = @"There are no more Kamans around you";
                }
                [self.tableView reloadData];
                
            }];
            if([self.kamans count] == 0) {
                statusText =  @"There are no more Kamans around you";
            } else {
                
            }
             [self.tableView reloadData];
        } else {
             statusText = @"There are no more Kamans around you";
            [self.tableView reloadData];
            NSLog(@"Error %@",error.localizedDescription);
        }
        
    }];
}


- (void)requestLocationAuthorization
{
    // this creates the CCLocationManager that will find your current location
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    // If the status is denied or only granted for when in use, display an alert
    if (status ==  kCLAuthorizationStatusDenied) {
        NSString *title;
        title =  @"Location services are off";
        NSString *message = @"This app needs to use your location info to find Kamans around you.";
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Settings", nil];
        [alertView show];
    }
    // The user has not enabled any location services. Request background authorization.
    else if (status == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestWhenInUseAuthorization];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // Send the user to the Settings for this app
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:settingsURL];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"Location manager auth status changed: %d",status);
    
    if(status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
    }
}

// this delegate is called when the app successfully finds your current location
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
   [geocoder reverseGeocodeLocation:manager.location
                   completionHandler:^(NSArray *placemarks, NSError *error) {
                       
                       if (error){
                           NSLog(@"Geocode failed with error: %@", error);
                           return;
                           
                       }
                       
                       CLPlacemark *placemark = [placemarks count] == 0 ? nil :[placemarks objectAtIndex:0];
                       
                       
                       if(placemark) {
                           [self.locationManager stopUpdatingLocation];
                           [self.locationManager startMonitoringSignificantLocationChanges];
                                                     
                           [Utils locallyStoreLocalPlace:placemark.locality fromCountry:placemark.country andCountryCode:placemark.ISOcountryCode withLocationLat:placemark.location.coordinate.latitude andLocationLon:placemark.location.coordinate.longitude onSuccess:^(id result) {
                               currentLocality = result;
                               NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                               
                               [[PFUser currentUser] updateUserColumn:@"LastKnownLocation" withValue:[PFGeoPoint geoPointWithLocation:placemark.location] onCallBack:^(id result) {
                                   
                               }];
                               [defaults setObject:currentLocality.name forKey:@"last_locality_name"];
                               [defaults setObject:currentLocality.countryCode forKey:@"last_locality_country_code"];
                               [defaults synchronize];
                           }];
                           
                        }
                       
                   }];
}


// this delegate method is called if an error occurs in locating your current location
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"locationManager:%@ didFailWithError:%@", manager, error);
}


-(void)onViewDetailsClicked
{
    [super onViewDetailsClicked];
    [Utils sendGoogleAnalyticsTrackEventOfCategory:@"ui_action" action:@"button_click" labeled:@"View Details" withValue:nil];
}

-(void)onKamanPictureClicked
{
    [super onKamanPictureClicked];
    [Utils sendGoogleAnalyticsTrackEventOfCategory:@"ui_action" action:@"image_click" labeled:@"Kaman Event Image" withValue:nil];
}

@end
