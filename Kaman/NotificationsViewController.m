//
//  NotificationsViewController.m
//  Kaman
//
//  Created by Moin' Victor on 23/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import "NotificationsViewController.h"
#import "KamanNotificationTableViewCell.h"
#import "Utils.h"
#import "HostKamanViewController.h"
#import "KamanDetailsViewController.h"
#import "KamanRequestsTableViewController.h"
#import "PickChatUserTableViewController.h"
#import "MessagesViewController.h"
#import "RateUserViewController.h"
#import "KamansTableEmptyView.h"
#import "LocalNotif.h"
#import "OtherNotifsTableViewController.h"
#import <DateTools/DateTools.h>

@interface NotificationsViewController ()
@property (nonatomic) UIRefreshControl *refreshControl;
@end
NSArray * userKamanSections;
NSMutableDictionary * userKamans;
NSArray * attendeeKamanSections;
NSMutableDictionary * attendeeKamans;
NSMutableDictionary * kamanPhotosDictionary;
NSMutableDictionary *kamanRequestsDictionary;
NSMutableDictionary * loadedNotifObjects;
NSTimer * fetch_notifs_timer;
UITableView * otherNotifsTableView;

@implementation NotificationsViewController


- (IBAction)exit:(id)sender {
    
   /* for (NSString *type in @[PUSH_TYPE_INVITE_ACCEPTED,PUSH_TYPE_RATED,PUSH_TYPE_REQUEST_ACCEPTED]) {
        [Utils deleteNotifsWithQuery:[NSString stringWithFormat: @"type = '%@'",type]];
    } */
    [self updateNotifBadgesThenReload:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)segmentClicked:(id)sender {
  //  [userKamans removeAllObjects];
   // [attendeeKamans removeAllObjects];
   // [self.tableView reloadData];
    if ([self.segmentControl selectedSegmentIndex] == 0) {
         [self searchKamansWithUserAsAttendee];
    } else {
        [self searchUserKamans];
    }
    [self sendGoogleAnalyticsTrackScreen];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateNotifBadgesThenReload:YES];
    
    fetch_notifs_timer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(fetchNotifs) userInfo:nil repeats:YES];
    
}

-(void) fetchNotifs
{
    [Utils fetchLocalNotifs:^(id result) {
        NSMutableArray * notifs = result;
        if([notifs count] > 0) {
            [self updateNotifBadgesThenReload:YES];
        }
    }];
}


-(IBAction) goSeeOtherNotifs
{
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        
        OtherNotifsTableViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"other_notifs"];
        //set properties
        UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:viewController];
        [navCon.navigationBar setBarTintColor:
         [UIColor whiteColor]];
        [navCon.navigationBar setTitleTextAttributes:
         @{NSForegroundColorAttributeName:MyOrangeColor}];
        
        [self presentModalViewController:navCon animated:YES];
    
}
    
    
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [fetch_notifs_timer invalidate];
}

-(void) updateNotifBadgesThenReload:(BOOL)reload
{
    [Utils updateNotifBadgeFor:[NSString stringWithFormat:@"target = 'Host' AND type IN {'%@','%@','%@'}",PUSH_TYPE_CHAT_MESSAGE, PUSH_TYPE_GROUP_MESSAGE,PUSH_TYPE_REQUESTED] toView:self.segmentControl position:MGBadgePositionTopRight];
    
    [Utils updateNotifBadgeFor:[NSString stringWithFormat:@"target = 'Attendee' AND type IN {'%@','%@','%@'}",PUSH_TYPE_CHAT_MESSAGE, PUSH_TYPE_GROUP_MESSAGE,PUSH_TYPE_INVITED] toView:self.fakeView position:MGBadgePositionTopRight];
    
    
    NSInteger announce = [Utils updateNotifBadgeFor:[NSString stringWithFormat:@"type IN {'%@','%@','%@'}",PUSH_TYPE_REQUEST_ACCEPTED, PUSH_TYPE_INVITE_ACCEPTED,PUSH_TYPE_RATED] toView:nil position:MGBadgePositionTopRight];
    
    UIView * view = [self.announceBarButton valueForKey:@"view"];
    if(announce > 0) {
        [view setHidden:NO];
    } else {
        [view setHidden:YES];
    }
    
    view.badgeView.badgeValue = announce;
    view.badgeView.badgeColor = DesignersBrownColor;
    view.badgeView.textColor = [UIColor blackColor];
    view.badgeView.position = MGBadgePositionKamanFix;
    [view.badgeView setOutlineWidth:2.0];
    [view.badgeView setOutlineColor:MyGreyColor];
    view.badgeView.horizontalOffset = 5.0;
    view.badgeView.verticalOffset = 5.0;

    if(reload)
        [self.tableView reloadData];
}

-(void) sendGoogleAnalyticsTrackScreen
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:self.segmentControl.selectedSegmentIndex == 0?  @"Attendee screen"  : @"Host screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if([userKamans count] ==0) {
        [self searchUserKamans];
    }
    
    [self sendGoogleAnalyticsTrackScreen];
    
    //kamanRequestsDictionary = [NSMutableDictionary new];
    //kamanPhotosDictionary = [NSMutableDictionary new];
   // [self.tableView reloadData];
    if([attendeeKamans count] ==0) {
        [self searchKamansWithUserAsAttendee];
    }
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    userKamans = [NSMutableDictionary new];
    userKamanSections = @[@"Upcoming",@"Past"];
    
    kamanPhotosDictionary = [NSMutableDictionary new];
    kamanRequestsDictionary = [NSMutableDictionary new];
    loadedNotifObjects = [NSMutableDictionary new];
    
    attendeeKamans = [NSMutableDictionary new];
    attendeeKamanSections = @[@"Invitations",@"Accepted", @"Awaiting Hosts Response"];
    
    [self.navigationController.navigationBar setBarTintColor:
     [UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:MyOrangeColor}];

    self.view.backgroundColor = MyBrownColor;
    self.tableView.backgroundColor = MyBrownColor;
    
    UINib *badicNib = [UINib nibWithNibName:@"KamanNotificationTableViewCell" bundle:nil];
    [[self tableView] registerNib:badicNib forCellReuseIdentifier:@"NotifCell"];
    
    
    UIImage *img = [UIImage imageNamed:@"notifications"];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [imgView setImage:img];
    // setContent mode aspect fit
    [imgView setContentMode:UIViewContentModeScaleAspectFit];
    self.navigationItem.titleView = imgView;
    
    // remove extra cells
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.allowsSelection = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    self.refreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];

}

-(void)resetAttendee
{
    NSMutableArray * invited = [NSMutableArray new];
    NSMutableArray * accepted = [NSMutableArray new];
    NSMutableArray * requested = [NSMutableArray new];
    [attendeeKamans setObject:invited forKey:[attendeeKamanSections objectAtIndex:0]];
    [attendeeKamans setObject:accepted forKey:[attendeeKamanSections objectAtIndex:1]];
    [attendeeKamans setObject:requested forKey:[attendeeKamanSections objectAtIndex:2]];
    [loadedNotifObjects removeAllObjects];
}


-(void) addChannelToCurrentUserForKaman: (PFObject*) kaman
{
    NSString * channel = [NSString stringWithFormat:@"KAMAN-%@", kaman.objectId];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:channel forKey:@"channels"];
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!succeeded) {
            [currentInstallation saveEventually];
        }
    }];
}

-(void) performAttendeeSearchQuery:(PFQuery*) query onCallBack: (ResultCallback) callback
{
    NSComparisonResult (^dateSorter)(id a,id b);
    
    dateSorter = ^NSComparisonResult(PFObject* a, PFObject* b) {
        PFObject *kaman_a = [a objectForKey:@"Kaman"];
        PFObject *kaman_b = [b objectForKey:@"Kaman"];
        
        NSDate *first = [kaman_a objectForKey:@"DateTime"];
        NSDate *second = [kaman_b objectForKey:@"DateTime"];
        return [second compare:first];
    };
    
    [self.tableView reloadData];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [self.refreshControl endRefreshing];
        if(!error) {
            if([objects count] > 0) {
                NSMutableArray * invited = [attendeeKamans objectForKey:[attendeeKamanSections objectAtIndex:0]];
                NSMutableArray * accepted = [attendeeKamans objectForKey:[attendeeKamanSections objectAtIndex:1]];
                NSMutableArray * requested = [attendeeKamans objectForKey:[attendeeKamanSections objectAtIndex:2]];
                for (PFObject * obj in objects) {
                    PFObject * loaded = [loadedNotifObjects objectForKey:obj.objectId];
                    NSNumber *acceptedNSNumber = [obj objectForKey: @"Accepted"];
                    bool acceptedBoolean = [acceptedNSNumber boolValue];
                    [obj fetchIfNeededInBackground];
                    if(acceptedBoolean) {
                        if(!loaded) {
                            [accepted addObject:obj];
                            [loadedNotifObjects setObject:obj forKey:obj.objectId];
                        }
                        
                        // Subscibe to this party for Group chat
                        PFObject *kaman = [obj objectForKey:@"Kaman"];
                        [self addChannelToCurrentUserForKaman:kaman];
                        
                    } else {
                        if([[obj parseClassName] isEqualToString:@"KamanInvite"]) { // invites
                            if(!loaded) {
                                [invited addObject:obj];
                                [loadedNotifObjects setObject:obj forKey:obj.objectId];
                            }
                        } else { // requests
                            if(!loaded) {
                                [requested addObject:obj];
                                [loadedNotifObjects setObject:obj forKey:obj.objectId];
                            }
                        }
                    }
                }
                [attendeeKamans setObject:[NSMutableArray arrayWithArray:[requested sortedArrayUsingComparator:dateSorter]] forKey:[attendeeKamanSections objectAtIndex:2]];
                [attendeeKamans setObject:[NSMutableArray arrayWithArray:[accepted sortedArrayUsingComparator:dateSorter]] forKey:[attendeeKamanSections objectAtIndex:1]];
                [attendeeKamans setObject:[NSMutableArray arrayWithArray:[invited sortedArrayUsingComparator:dateSorter]] forKey: [attendeeKamanSections objectAtIndex:0]];
            } else {
                NSLog(@"There are no more Kamans around you posted by you");
                [self.tableView reloadData];
            }
        } else {
            NSLog(@"%@",error);
        }
        if(callback) {
            callback(nil);
        }
        [self.tableView reloadData];
    }];
}

-(void)searchKamansWithUserAsAttendee
{
    [self.refreshControl beginRefreshing];
    [self resetAttendee];
    
    PFQuery *removeArchivedQuery = [PFQuery queryWithClassName:@"Kaman"];
    [removeArchivedQuery whereKey:@"objectId" notContainedIn:[[PFUser currentUser] objectForKey:@"ArchivedKamans"]];
    [removeArchivedQuery whereKey:@"Archived" notEqualTo:[NSNumber numberWithBool:YES]];
    
    PFQuery *query1 = [PFQuery queryWithClassName:@"KamanRequest"];
    [query1 whereKey:@"RequestingUser" equalTo:[PFUser currentUser]];
    [query1 includeKey:@"Kaman"];
    [query1 includeKey:@"Kaman.Area"];
    [query1 includeKey:@"Kaman.Host"];
    // filter archived
    [query1 whereKey:@"Kaman" matchesQuery:removeArchivedQuery];
    [query1 includeKey:@"RequestingUser"];
    
    PFQuery *query2 = [PFQuery queryWithClassName:@"KamanInvite"];
    [query2 whereKey:@"InvitedUser" equalTo:[PFUser currentUser]];
    [query2 includeKey:@"Kaman"];
    [query2 includeKey:@"Kaman.Area"];
    // filter archived
    [query2 whereKey:@"Kaman" matchesQuery:removeArchivedQuery];
    /*[query2 whereKey:@"Kaman.objectId" notContainedIn:[[PFUser currentUser] objectForKey:@"ArchivedKamans"]];
    [query2 whereKey:@"Kaman.Archived" notEqualTo:[NSNumber numberWithBool:YES]];*/
    [query2 includeKey:@"Kaman.Host"];
    [query2 includeKey:@"InvitedUser"];
    
    [self performAttendeeSearchQuery:query1 onCallBack:^(id result) {
        [self performAttendeeSearchQuery:query2 onCallBack:nil];
    }];
    


}

-(void) searchUserKamans
{
    NSComparisonResult (^dateSorter)(id a,id b);
    
    dateSorter = ^NSComparisonResult(id a, id b) {
        NSDate *first = [(PFObject*)a objectForKey:@"DateTime"];
        NSDate *second = [(PFObject*)b objectForKey:@"DateTime"];
        return [second compare:first];
    };

    
    [self.refreshControl beginRefreshing];
    [self.tableView reloadData];
    PFQuery *query = [PFQuery queryWithClassName:@"Kaman"];
    
    //[query fromLocalDatastore]
    // Interested in locations near user.
    [query whereKey:@"Host" equalTo:[PFUser currentUser]];
    [query includeKey:@"Area"];
    [query whereKey:@"Archived" notEqualTo:[NSNumber numberWithBool:YES]];
    [query includeKey:@"Host"];
    // Limit what could be a lot of points.
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [self.refreshControl endRefreshing];
        if(!error) {
            if([objects count] > 0) {
                
                [userKamans removeAllObjects];
                NSMutableArray * upcoming = [NSMutableArray new];
                NSMutableArray * past = [NSMutableArray new];
                for (PFObject * kaman in objects) {
                   // Subscibe to this party for Group chat
                    [self addChannelToCurrentUserForKaman:kaman];
                    
                    NSDate * today = [NSDate date];
                    NSComparisonResult result = [today compare:[kaman objectForKey:@"DateTime"]];
                    switch (result)
                    {
                        case NSOrderedAscending:
                            if(![upcoming containsObject:kaman]) {
                                [upcoming addObject:kaman];
                            }
                            break;
                        case NSOrderedDescending:
                        case NSOrderedSame: {
                            if(![past containsObject:kaman]) {
                                [past addObject:kaman];
                            }
                             break;
                        }
                        default:
                            NSLog(@"Error Comparing Dates");
                            break;
                    }
                }
                [userKamans setObject:[NSMutableArray arrayWithArray:[past sortedArrayUsingComparator:dateSorter]] forKey:@"Past"];
                [userKamans setObject:[NSMutableArray arrayWithArray:[upcoming sortedArrayUsingComparator:dateSorter]] forKey:@"Upcoming"];
                
            } else {
                NSLog(@"There are no more Kamans around you posted by you");
            }
        } else {
            NSLog(@"%@",error);
        }
        [self.tableView reloadData];
        
    }];

}

- (void)refreshTable {
    //TODO: refresh your data
    [self.refreshControl beginRefreshing];
    
    if([self.segmentControl selectedSegmentIndex] == 1) {
        [self searchUserKamans];
    } else {
        [self searchKamansWithUserAsAttendee];
    }
   // [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)hostKaman:(id)sender
{
    [self performSegueWithIdentifier:@"go_host_kaman" sender:nil];
}


-(void) setEmptyView
{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"KamansTableEmptyView"owner:self options:nil];
    int startIndex;
#ifdef __IPHONE_2_1
    startIndex = 0;
#else
    startIndex = 1;
#endif
    KamansTableEmptyView* myView = [ nibViews objectAtIndex: startIndex];
    myView.backgroundColor = MyBrownColor;
    
    
    [myView.inviteButton setAlpha:0.0];
    [myView.animImageView setAlpha:0.0];
    [myView.statusLabel setText:self.segmentControl.selectedSegmentIndex == 0 ? @"Not attending or invited to any Kamans" :  @"You have not hosted any Kamans yet"];
    /*[myView.hostButton removeTarget:nil
                                 action:NULL
                       forControlEvents:UIControlEventAllEvents]; */
    
    [myView.hostButton setAlpha:self.segmentControl.selectedSegmentIndex == 0  ? 0.0 : 1.0];
    [Utils styleButton:myView.hostButton bgColor:MyOrangeColor highlightColor:MyGreyColor];
    [myView.hostButton addTarget:self action:@selector(hostKaman:) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView.backgroundView = myView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
     if ([self.segmentControl selectedSegmentIndex] == 0) {
         int realCount = 0;
         for (NSMutableArray * arr in [attendeeKamans allValues]) {
             realCount += [arr count];
         }
         
         if(realCount > 0) {
             self.tableView.backgroundView = nil;
             self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
             return [attendeeKamans count];
             
         } else {
             [self setEmptyView];
         }
        
     }
    
    if ([self.segmentControl selectedSegmentIndex] == 1) {
        
        int realCount = 0;
        for (NSMutableArray * arr in [userKamans allValues]) {
            realCount += [arr count];
        }
        
         if (realCount > 0) {
             
             self.tableView.backgroundView = nil;
             self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
             return [userKamans count];
         } else {
             [self setEmptyView];
         }
         
     }
    
    return 0;
    
}

-(void)deletekaman: (PFObject*)kaman fromKamans:(NSMutableArray*) array atIndex: (NSUInteger) index listObject: (PFObject*) obj
{
    PFUser * host = [kaman objectForKey:@"Host"];
    if([host.objectId isEqualToString:[PFUser currentUser].objectId]) { // is hosted by user
        [kaman setObject:[NSNumber numberWithBool:YES] forKey:@"Archived"];
        [kaman saveInBackground];
    } else {
        [[PFUser currentUser] addUniqueObject:kaman.objectId forKey:@"ArchivedKamans"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if(error) {
                [[PFUser currentUser] saveEventually];
            }
        }];
    }
    if(array) {
        @try {
             [array removeObjectAtIndex:index];
        }
        @catch (NSException *exception) {
            [array removeObject:obj];

        }
        @finally {
            
        }
       
    }
    [loadedNotifObjects removeObjectForKey:obj.objectId];
    
    [Utils deleteNotifsWithQuery:[NSString stringWithFormat: @"kamanId = '%@'",kaman.objectId]];
    [self updateNotifBadgesThenReload:YES];
}


-(void) editKaman:(id) sender
{
    UIButton * btn = sender;
    NSMutableArray * array = [userKamans objectForKey:[userKamanSections objectAtIndex:0]];
    
    PFObject *kaman = [array objectAtIndex:btn.tag];
    [kaman fetchIfNeededInBackground];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    HostKamanViewController *someViewController = [storyboard instantiateViewControllerWithIdentifier:@"host_kaman"];
    someViewController.kaman = kaman;
    [self.navigationController pushViewController:someViewController animated:YES];
    
}

-(void)didSelectAttendee:(PFUser *)user withAvatar:(UIImage *)image forKaman:(PFObject *)kaman
{
    [self dismissModalViewControllerAnimated:YES];
  
    [self goToMessageWith:user userAvatar:image aboutKaman:kaman];
    
   }

-(void) goToMessageWith:(PFUser*) user userAvatar:(UIImage*) image aboutKaman:(PFObject*) kaman
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    MessagesViewController *someViewController = [storyboard instantiateViewControllerWithIdentifier:@"messages"];
    someViewController.users = [NSMutableDictionary dictionaryWithObject:user forKey:user.objectId];
    someViewController.isGroupChat = NO;
    someViewController.kaman = kaman;
    someViewController.avatars = [NSMutableDictionary dictionaryWithObject:
                                  [JSQMessagesAvatarImageFactory avatarImageWithImage:image
                                                                             diameter:72.0]forKey:user.objectId];
    [self.navigationController pushViewController:someViewController animated:YES];

}

-(void) hostRateAttendeePastKaman:(id) sender
{
    UIButton * btn = sender;
    NSMutableArray * array = [userKamans objectForKey:[userKamanSections objectAtIndex:1]];
    
    PFObject *kaman = [array objectAtIndex:btn.tag];
    [kaman fetchIfNeededInBackground];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    RateUserViewController *someViewController = [storyboard instantiateViewControllerWithIdentifier:@"rate_user"];
    someViewController.kaman = kaman;
    
    [Utils setTitle:@"Rate Attendees" withColor:MyOrangeColor andSubTitle:[kaman objectForKey:@"Name"] withColor:MyOrangeColor onNavigationController:someViewController];
    [self.navigationController pushViewController:someViewController animated:YES];
}

-(void) messageGroupUpcomingKaman:(id) sender
{
    UIButton * btn = sender;
    NSMutableArray * array = [userKamans objectForKey:[userKamanSections objectAtIndex:0]];
    
    PFObject *kaman = [array objectAtIndex:btn.tag];
    [kaman fetchIfNeededInBackground];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    MessagesViewController *someViewController = [storyboard instantiateViewControllerWithIdentifier:@"messages"];
    someViewController.kaman = kaman;
    someViewController.isGroupChat = YES;
    
    [self.navigationController pushViewController:someViewController animated:YES];
}

-(void) messageGroupPastKaman:(id) sender
{
    UIButton * btn = sender;
    NSMutableArray * array = [userKamans objectForKey:[userKamanSections objectAtIndex:1]];
    
    PFObject *kaman = [array objectAtIndex:btn.tag];
    [kaman fetchIfNeededInBackground];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    MessagesViewController *someViewController = [storyboard instantiateViewControllerWithIdentifier:@"messages"];
    someViewController.kaman = kaman;
    someViewController.isGroupChat = YES;
    
    [self.navigationController pushViewController:someViewController animated:YES];
}


-(void) attendeeRateHostAndAttendeePastKaman:(id) sender
{
    UIButton * btn = sender;
    NSMutableArray * array = [attendeeKamans objectForKey:[attendeeKamanSections objectAtIndex:1]];
    
    PFObject *kaman = [[array objectAtIndex:btn.tag] objectForKey:@"Kaman"];
    [kaman fetchIfNeededInBackground];
    
    PFUser * host = [kaman objectForKey:@"Host"];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    RateUserViewController *someViewController = [storyboard instantiateViewControllerWithIdentifier:@"rate_user"];
    someViewController.kaman = kaman;
    someViewController.ratingHost = YES;
    someViewController.users = [NSMutableArray arrayWithObject:host];
    [Utils setTitle:@"Rate Host" withColor:MyOrangeColor andSubTitle:[kaman objectForKey:@"Name"] withColor:MyOrangeColor onNavigationController:someViewController];
    [self.navigationController pushViewController:someViewController animated:YES];
}

-(void) messageAttendeeUpcomingKaman:(id) sender
{
    UIButton * btn = sender;
    NSMutableArray * array = [userKamans objectForKey:[userKamanSections objectAtIndex:0]];
    
    PFObject *kaman = [array objectAtIndex:btn.tag];
    [kaman fetchIfNeededInBackground];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    PickChatUserTableViewController *someViewController = [storyboard instantiateViewControllerWithIdentifier:@"kaman_users"];
    someViewController.kaman = kaman;
    someViewController.pickChatUserDelegate = self;
    // This is where you wrap the view up nicely in a navigation controller
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:someViewController];
    
    // You can even set the style of stuff before you show it
    navigationController.navigationBar.barStyle = UIBarStyleDefault;
   
    // And now you want to present the view in a modal fashion
    [self presentModalViewController:navigationController animated:YES];
}

-(void) messageAttendeePastKaman:(id) sender
{
    UIButton * btn = sender;
    NSMutableArray * array = [userKamans objectForKey:[userKamanSections objectAtIndex:1]];
    
    PFObject *kaman = [array objectAtIndex:btn.tag];
    [kaman fetchIfNeededInBackground];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    PickChatUserTableViewController *someViewController = [storyboard instantiateViewControllerWithIdentifier:@"kaman_users"];
    someViewController.kaman = kaman;
    someViewController.pickChatUserDelegate = self;
    // This is where you wrap the view up nicely in a navigation controller
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:someViewController];
    
    // You can even set the style of stuff before you show it
    navigationController.navigationBar.barStyle = UIBarStyleDefault;
    
    // And now you want to present the view in a modal fashion
    [self presentModalViewController:navigationController animated:YES];
}

-(void) messageHostAcceptedKaman:(id) sender
{
    UIButton * btn = sender;
     NSMutableArray * array = [attendeeKamans objectForKey:[attendeeKamanSections objectAtIndex:1]];
    
    PFObject *kaman = [[array objectAtIndex:btn.tag] objectForKey:@"Kaman"];
    [kaman fetchIfNeededInBackground];
    
   /* UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    PickChatUserTableViewController *someViewController = [storyboard instantiateViewControllerWithIdentifier:@"kaman_users"];
    someViewController.kaman = kaman;
    someViewController.pickChatUserDelegate = self;
    // This is where you wrap the view up nicely in a navigation controller
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:someViewController];
    
    // You can even set the style of stuff before you show it
    navigationController.navigationBar.barStyle = UIBarStyleDefault;
    
    // And now you want to present the view in a modal fashion
    [self presentModalViewController:navigationController animated:YES];
    */
      [self goToMessageWith:[kaman objectForKey:@"Host"] userAvatar:[UIImage imageNamed:@"person"] aboutKaman:kaman];
    
}


-(void) messageGroupAcceptedKaman:(id) sender
{
    UIButton * btn = sender;
    NSMutableArray * array = [attendeeKamans objectForKey:[attendeeKamanSections objectAtIndex:1]];
    
    PFObject *kaman = [[array objectAtIndex:btn.tag] objectForKey:@"Kaman"];
    [kaman fetchIfNeededInBackground];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    MessagesViewController *someViewController = [storyboard instantiateViewControllerWithIdentifier:@"messages"];
    someViewController.kaman = kaman;
    someViewController.isGroupChat = YES;
    
    [self.navigationController pushViewController:someViewController animated:YES];
}


-(void) viewKamanAsHost:(id) sender
{
    UIButton * btn = sender;
    NSMutableArray * array = [userKamans objectForKey:[userKamanSections objectAtIndex:1]];
    
    PFObject *kaman = [array objectAtIndex:btn.tag];
    [kaman fetchIfNeededInBackground];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    KamanDetailsViewController *someViewController = [storyboard instantiateViewControllerWithIdentifier:@"kaman_details"];
    someViewController.kamans = [NSMutableArray arrayWithObject:kaman];
    someViewController.showAddress = YES;
    someViewController.showButtons = NO;
    someViewController.customTitle = [kaman objectForKey:@"Name"];
    [self.navigationController pushViewController:someViewController animated:YES];
}

-(void) viewKamanRequestsAsHost:(id) sender
{
    UIButton * btn = sender;
    NSMutableArray * array = [userKamans objectForKey:[userKamanSections objectAtIndex:0]];
    
    PFObject *kaman = [array objectAtIndex:btn.tag];
    [kaman fetchIfNeededInBackground];
    
    NSArray *kamanRequests =  [kamanRequestsDictionary objectForKey:kaman.objectId];
    
    NSMutableArray *kamanRequestsCopied = [NSMutableArray new];
    [kamanRequestsCopied addObjectsFromArray:kamanRequests];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    KamanRequestsTableViewController *someViewController = [storyboard instantiateViewControllerWithIdentifier:@"kaman_requests"];
    someViewController.kaman = kaman;
    someViewController.kamanRequests = [NSMutableArray arrayWithArray:kamanRequestsCopied];
    [self.navigationController pushViewController:someViewController animated:YES];
    [kamanRequestsDictionary removeObjectForKey:kaman.objectId]; // so next time we load again
}

-(void) viewInvitedKamanAsAttendee:(id) sender
{
    UIButton * btn = sender;
    NSMutableArray * array = [attendeeKamans objectForKey:[attendeeKamanSections objectAtIndex:0]];
    
    PFObject *kaman = [[array objectAtIndex:btn.tag] objectForKey:@"Kaman"];
    [kaman fetchIfNeededInBackground];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    KamanDetailsViewController *someViewController = [storyboard instantiateViewControllerWithIdentifier:@"kaman_details"];
    someViewController.kamans = [NSMutableArray arrayWithObject:kaman];
    someViewController.customTitle = [kaman objectForKey:@"Name"];
    someViewController.showButtons = NO;
    [self.navigationController pushViewController:someViewController animated:YES];
}

-(void) viewAcceptedKamanAsAttendee:(id) sender
{
    UIButton * btn = sender;
    NSMutableArray * array = [attendeeKamans objectForKey:[attendeeKamanSections objectAtIndex:1]];
    
    PFObject *kaman = [[array objectAtIndex:btn.tag] objectForKey:@"Kaman"];
    [kaman fetchIfNeededInBackground];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    KamanDetailsViewController *someViewController = [storyboard instantiateViewControllerWithIdentifier:@"kaman_details"];
     someViewController.showAddress = YES;
     someViewController.showButtons = NO;
    someViewController.customTitle = [kaman objectForKey:@"Name"];
    someViewController.kamans = [NSMutableArray arrayWithObject:kaman];
    [self.navigationController pushViewController:someViewController animated:YES];
}

-(void) viewRequestedKamanAsAttendee:(id) sender
{
    UIButton * btn = sender;
    NSMutableArray * array = [attendeeKamans objectForKey:[attendeeKamanSections objectAtIndex:2]];
    
    PFObject *kaman = [[array objectAtIndex:btn.tag] objectForKey:@"Kaman"];
    [kaman fetchIfNeededInBackground];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    KamanDetailsViewController *someViewController = [storyboard instantiateViewControllerWithIdentifier:@"kaman_details"];
    someViewController.kamans = [NSMutableArray arrayWithObject:kaman];
    someViewController.showAddress = NO;
    someViewController.customTitle = [kaman objectForKey:@"Name"];
    [self.navigationController pushViewController:someViewController animated:YES];
}

-(void) acceptInvitation:(id) sender
{
     
    UIButton * btn = sender;
    NSMutableArray * array = [attendeeKamans objectForKey:[attendeeKamanSections objectAtIndex:0]];
    NSMutableArray * accepted = [attendeeKamans objectForKey:[attendeeKamanSections objectAtIndex:1]];
    PFObject *kamanInvite = [array objectAtIndex:btn.tag];
    PFObject *kaman = [kamanInvite objectForKey:@"Kaman"];
    PFUser *host = [kaman objectForKey:@"Host"];
    
    [kamanInvite setObject:[NSNumber numberWithBool:YES] forKey:@"Accepted"];
    [kamanInvite saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error) {
            
            [array removeObject:kamanInvite];
            if(![accepted containsObject:kamanInvite]) {
                [accepted addObject:kamanInvite];
            }
            
            // incremented attended kamans
            [[PFUser currentUser] addUniqueObjectsFromArray:[NSArray arrayWithObject:kaman.objectId] forKey:@"KamansAttended"];
            [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(error) {
                    [[PFUser currentUser] saveEventually];
                    NSLog(@"Error updating KamansAttended Invite: %@",error.localizedDescription);
                }
            }];

            // Subscibe to this party for Group chat
            PFInstallation *currentInstallation = [PFInstallation currentInstallation];
            [currentInstallation addUniqueObject:[NSString stringWithFormat:@"KAMAN-%@", kaman.objectId] forKey:@"channels"];
            [currentInstallation saveInBackground];
            NSString * query =  [NSString stringWithFormat: @"kamanId = '%@' AND type = '%@' AND senderId = '%@'",kaman.objectId,PUSH_TYPE_INVITED,host.objectId];
            [Utils deleteNotifsWithQuery:query];
            [self updateNotifBadgesThenReload:YES];
            
            [Utils sendPushFor:PUSH_TYPE_INVITE_ACCEPTED toUser:host withMessage:[NSString stringWithFormat: @"%@ has accepted your invitation to attend '%@'.",[[PFUser currentUser] displayName],[kaman objectForKey:@"Name"]] ForKaman:kaman];
            [self.tableView reloadData];
        } else {
            [Utils showMessageHUDInView:self.view withMessage:[error localizedDescription] afterError:YES];
        }
    }];
    
}

-(void) declineInvitation: (id) sender
{
    
    UIButton * btn = sender;
    NSMutableArray * array = [attendeeKamans objectForKey:[attendeeKamanSections objectAtIndex:0]];
    PFObject *kamanInvite = [array objectAtIndex:btn.tag];
    PFObject *kaman = [kamanInvite objectForKey:@"Kaman"];
    PFUser *host = [kaman objectForKey:@"Host"];
    
    [kamanInvite deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error) {
            [array removeObject:kamanInvite];
            [self.tableView reloadData];
            [loadedNotifObjects removeObjectForKey:kamanInvite.objectId];
            [Utils deleteNotifsWithQuery:[NSString stringWithFormat: @"kamanId = '%@' AND type = '%@' AND senderId = '%@'",kaman.objectId,PUSH_TYPE_INVITED,host.objectId]];
            [self updateNotifBadgesThenReload:YES];
            
        } else {
            [Utils showMessageHUDInView:self.view withMessage:[error localizedDescription] afterError:YES];
        }
    }];

}

-(CGFloat) calculateHeight
{
    if(IS_IPHONE_6 || IS_IPHONE_5) {
        return 100;
    }
    CGFloat height = self.tableView.frame.size.width - (70*3) - 40;
    if(height <= 50) {
        height = 90;
    }
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = [self calculateHeight];
    
    NSLog(@"Height = %f",height);
    return height;
}
// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if([self.segmentControl selectedSegmentIndex] == 0) {
        if([attendeeKamans count] == 0) {
            return 0.0;
        }
        NSMutableArray * array = [attendeeKamans objectForKey:[attendeeKamanSections objectAtIndex:section]];
        if([array count] == 0) {
            return 0.0;
        }

        return 35.0;
    } else {
        if([userKamans count] == 0) {
            return 0.0;
        }
        NSMutableArray * array = [userKamans objectForKey:[userKamanSections objectAtIndex:section]];
        if([array count] == 0) {
            return 0.0;
        }
        return 35.0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(self.segmentControl.selectedSegmentIndex == 0) {
        if([attendeeKamans count] == 0) {
            return nil;
        }
    } else {
        if([userKamans count] == 0) {
            return nil;
        }
    }
    NSString *sectionName =  ([self.segmentControl selectedSegmentIndex] == 0) ?
    [attendeeKamanSections objectAtIndex:section]
    :[userKamanSections objectAtIndex:section];

    return sectionName;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSMutableArray * array =
    [self.segmentControl selectedSegmentIndex] == 0
    ?[attendeeKamans objectForKey:[attendeeKamanSections objectAtIndex:indexPath.section]]
    :[userKamans objectForKey:[userKamanSections objectAtIndex:indexPath.section]];
     PFObject *kaman = [self.segmentControl selectedSegmentIndex] == 0 ? [[array objectAtIndex:indexPath.row] objectForKey:@"Kaman"] : [array objectAtIndex:indexPath.row];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        [self deletekaman: kaman fromKamans:array atIndex:indexPath.row listObject:[array objectAtIndex:indexPath.row]];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.segmentControl.selectedSegmentIndex == 0) {
        if([attendeeKamans count] == 0) {
            return 0;
        }
    } else {
        if([userKamans count] == 0) {
            return 0;
        }
    }
    return [self.segmentControl selectedSegmentIndex] == 0 ?
        [[attendeeKamans objectForKey:[attendeeKamanSections objectAtIndex:section]] count]
    : [[userKamans objectForKey:[userKamanSections objectAtIndex:section]] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray * array =
    [self.segmentControl selectedSegmentIndex] == 0
    ?[attendeeKamans objectForKey:[attendeeKamanSections objectAtIndex:indexPath.section]]
    :[userKamans objectForKey:[userKamanSections objectAtIndex:indexPath.section]];
    
    PFObject *kaman = [self.segmentControl selectedSegmentIndex] == 0 ? [[array objectAtIndex:indexPath.row] objectForKey:@"Kaman"] : [array objectAtIndex:indexPath.row];
    PFObject *kamanArea = [kaman objectForKey:@"Area"];
    [kamanArea fetchIfNeededInBackground];
    
    PFObject *kamanHost = [kaman objectForKey:@"Host"];
    [kamanHost fetchIfNeededInBackground];
    NSDate * kamanDate = [kaman objectForKey:@"DateTime"];
    
    KamanNotificationTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"NotifCell"];
        cell.backgroundColor = [UIColor whiteColor];
        [cell.kamanImageView setUserInteractionEnabled:YES];
    cell.imageViewHeightConstraint.constant = (IS_IPHONE_6 || IS_IPHONE_5 ? 72.0 : [self calculateHeight] -  20);
    cell.imageViewWidthConstraint.constant = (IS_IPHONE_6 || IS_IPHONE_5 ? 72.0 : [self calculateHeight] -  20);
        [cell setNeedsDisplay];
    
    NSLog(@"Image Height = %f",cell.imageViewHeightConstraint.constant);

    cell.editViewButton.tag = indexPath.row;
    cell.button1.tag = indexPath.row;
    cell.button2.tag = indexPath.row;
    cell.button3.tag = indexPath.row;
    
    // reset actions
    [cell.editViewButton removeTarget:nil
                               action:NULL
                     forControlEvents:UIControlEventAllEvents];
    [cell.button1 removeTarget:nil
                               action:NULL
                     forControlEvents:UIControlEventAllEvents];
    [cell.button2 removeTarget:nil
                               action:NULL
                     forControlEvents:UIControlEventAllEvents];
    [cell.button3 removeTarget:nil
                               action:NULL
                     forControlEvents:UIControlEventAllEvents];
    cell.button1.badgeView.badgeValue = 0;
    cell.button2.badgeView.badgeValue = 0;
    cell.button3.badgeView.badgeValue = 0;
    
    [self updateNotifBadgesThenReload:NO];
    
    if(self.segmentControl.selectedSegmentIndex == 1) { // Host section
        [cell.button1 setTitle: @"Message Attendee" forState:UIControlStateNormal];
        [cell.button2 setTitle: @"Message Group" forState:UIControlStateNormal];
        [Utils setUIView:cell.button3 backgroundColor:[UIColor whiteColor] andRoundedByRadius:3 withBorderColor:MyOrangeColor];
        [cell.button3 setTitleColor:MyOrangeColor forState:UIControlStateNormal];
       
        NSInteger requests = [Utils updateNotifBadgeFor:[NSString stringWithFormat: @"target = 'Host' AND type = '%@' AND kamanId = '%@'",PUSH_TYPE_REQUESTED,kaman.objectId] toView:nil position:MGBadgePositionCenterLeft];
        
        NSInteger pmsgs = [Utils updateNotifBadgeFor:[NSString stringWithFormat: @"target = 'Host' AND type = '%@' AND kamanId = '%@'",PUSH_TYPE_CHAT_MESSAGE,kaman.objectId] toView:nil position:MGBadgePositionCenterLeft];
        
        NSInteger groupChats = [Utils updateNotifBadgeFor:[NSString stringWithFormat: @"target = 'Host' AND type = '%@' AND kamanId = '%@'",PUSH_TYPE_GROUP_MESSAGE,kaman.objectId] toView:nil position:MGBadgePositionCenterLeft];
        
       NSLog(@"Host private message [%@]: %lu",[kaman objectForKey:@"Name"],pmsgs);
        NSLog(@"Host Group message [%@]: %lu",[kaman objectForKey:@"Name"],groupChats);
        
        if(pmsgs > 0) {
            [cell.button1 setTitle: [NSString stringWithFormat: @"Msg Attendee (%lu)", pmsgs] forState:UIControlStateNormal];
        } else {
            [cell.button1 setTitle: @"Message Attendee" forState:UIControlStateNormal];
        }
        
        if(groupChats > 0) {
            [cell.button2 setTitle: [NSString stringWithFormat: @"Msg Group (%lu)", groupChats] forState:UIControlStateNormal];
            
        } else {
            [cell.button2 setTitle: @"Message Group" forState:UIControlStateNormal];
        }
        
        if(pmsgs > 0 || groupChats > 0 || requests > 0) {
            cell.backgroundColor = MyLightestGray;
        } else {
            cell.backgroundColor = [UIColor whiteColor];
        }

        if(indexPath.section == 1) { // Past section
            if(pmsgs > 0) {
                [cell.button1 addTarget:self action:@selector(messageAttendeePastKaman:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            if(groupChats > 0) {
                [cell.button2 addTarget:self action:@selector(messageGroupPastKaman:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            [Utils setUIView:cell.button1 backgroundColor:[UIColor whiteColor] andRoundedByRadius:3 withBorderColor:MyGreyColor];
            [cell.button1 setTitleColor:MyGreyColor forState:UIControlStateNormal];
            
            [Utils setUIView:cell.button2 backgroundColor:[UIColor whiteColor] andRoundedByRadius:3 withBorderColor:MyGreyColor];
            [cell.button2 setTitleColor:MyGreyColor forState:UIControlStateNormal];
           
            [Utils setUIView:cell.button3 backgroundColor:[UIColor whiteColor] andRoundedByRadius:3 withBorderColor:MyOrangeColor];
            [cell.button3 setTitleColor:MyOrangeColor forState:UIControlStateNormal];
            
            [cell.editViewButton setTitle:@"View Details" forState:UIControlStateNormal];
            [cell.editViewButton setTitleColor:MyOrangeColor forState:UIControlStateNormal];
            
            [cell.editViewButton addTarget:self action:@selector(viewKamanAsHost:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.button3 setTitle: @"Rate Attendee" forState:UIControlStateNormal];
            [cell.button3 setAlpha:1.0];
            [cell.button3 addTarget:self action:@selector(hostRateAttendeePastKaman:) forControlEvents:UIControlEventTouchUpInside];
            
        } else { // Up comming
            
            
            [Utils setUIView:cell.button1 backgroundColor:[UIColor whiteColor] andRoundedByRadius:3 withBorderColor:MyOrangeColor];
            
            [Utils setUIView:cell.button2 backgroundColor:[UIColor whiteColor] andRoundedByRadius:3 withBorderColor:MyOrangeColor];
            
            [Utils setUIView:cell.button3 backgroundColor:[UIColor whiteColor] andRoundedByRadius:3 withBorderColor:MyOrangeColor];
            
            [cell.editViewButton setTitle:@"Edit Details" forState:UIControlStateNormal];
            [cell.editViewButton setTitleColor:MyOrangeColor forState:UIControlStateNormal];
            
            [cell.editViewButton removeTarget:nil
                                       action:NULL
                             forControlEvents:UIControlEventAllEvents];

            [cell.editViewButton addTarget:self action:@selector(editKaman:) forControlEvents:UIControlEventTouchUpInside];
           
            [cell.button1 addTarget:self action:@selector(messageAttendeeUpcomingKaman:) forControlEvents:UIControlEventTouchUpInside];
            [cell.button2 addTarget:self action:@selector(messageGroupUpcomingKaman:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.button3 addTarget:self action:@selector(viewKamanRequestsAsHost:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.button1 setTitleColor:MyOrangeColor forState:UIControlStateNormal];
            [cell.button2 setTitleColor:MyOrangeColor forState:UIControlStateNormal];
            [cell.button3 setTitleColor:MyOrangeColor forState:UIControlStateNormal];
            [cell.button3 setAlpha:1.0];

            [cell.button3 setTitle: @"Requests (0)" forState:UIControlStateNormal];
        }
        
        NSArray *kamanRequests = [kamanRequestsDictionary objectForKey:kaman.objectId];
        
        if(!kamanRequests) {
            [cell.button3 setTitle:@"Requests" forState:UIControlStateNormal];
            
            // create a relation based on the authors key
            PFRelation *relation = [kaman relationForKey:@"Requests"];
            
            // generate a query based on that relation
            PFQuery *query = [relation query];
            [query includeKey:@"RequestingUser"];
            [query includeKey:@"Kaman"];
            [query includeKey:@"Kaman.Area"];
            [query includeKey:@"Kaman.Host"];
            [query whereKey:@"Accepted" notEqualTo:[NSNumber numberWithBool:YES]];
            [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                if(!error) {
                    [kamanRequestsDictionary setObject:objects forKey:kaman.objectId];
                    if(indexPath.section == 1) { // Past section
                        [cell.button3 setTitle: @"Rate Attendee" forState:UIControlStateNormal];
                    } else {
                        
                        [cell.button3 setTitle:[NSString stringWithFormat: @"Requests (%lu)",(unsigned long)[objects count]] forState:UIControlStateNormal];
                        if([objects count] > 0) {
                            cell.backgroundColor = MyLightestGray;
                        } else {
                            if(pmsgs > 0 || groupChats > 0) {
                                cell.backgroundColor = MyLightestGray;
                            } else {
                                cell.backgroundColor = [UIColor whiteColor];
                            }
                        }

                        [cell.button3 removeTarget:nil
                                            action:NULL
                                  forControlEvents:UIControlEventAllEvents];
                        
                        [cell.button3 addTarget:self action:@selector(viewKamanRequestsAsHost:) forControlEvents:UIControlEventTouchUpInside];
                    }
                } else {
                    NSLog(@"Error fetching photos for %@: %@",[kaman objectForKey:@"Name"],error);
                }
            }];
        } else {
            if(indexPath.section == 1) { // Past section
                 [cell.button3 setTitle: @"Rate Attendee" forState:UIControlStateNormal];
            } else {
                [cell.button3 setTitle:[NSString stringWithFormat: @"Requests (%lu)",(unsigned long)[kamanRequests count]] forState:UIControlStateNormal];
                if([kamanRequests count] > 0) {
                    cell.backgroundColor = MyLightestGray;
                } else {
                    if(pmsgs > 0 || groupChats > 0) {
                        cell.backgroundColor = MyLightestGray;
                    } else {
                        cell.backgroundColor = [UIColor whiteColor];
                    }
                }

                [cell.button3 addTarget:self action:@selector(viewKamanRequestsAsHost:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    } else { // Attendee section
        [cell.button1 setTitle: @"Message Host" forState:UIControlStateNormal];
        [cell.button2 setTitle: @"Message Group" forState:UIControlStateNormal];
        [cell.editViewButton setTitle:@"View Details" forState:UIControlStateNormal];
        
        NSInteger invites = [Utils updateNotifBadgeFor:[NSString stringWithFormat: @"target = 'Attendee' AND type = '%@' AND kamanId = '%@'",PUSH_TYPE_INVITED,kaman.objectId] toView:nil position:MGBadgePositionCenterLeft];
        
        NSInteger pmsgs = [Utils updateNotifBadgeFor:[NSString stringWithFormat: @"target = 'Attendee' AND type = '%@' AND kamanId = '%@'",PUSH_TYPE_CHAT_MESSAGE,kaman.objectId] toView:nil position:MGBadgePositionBottomLeft];
        
        NSInteger groupChats =[Utils updateNotifBadgeFor:[NSString stringWithFormat: @"target = 'Attendee' AND type = '%@' AND kamanId = '%@'",PUSH_TYPE_GROUP_MESSAGE,kaman.objectId] toView:nil position:MGBadgePositionBottomLeft];
        
        if(pmsgs > 0 || groupChats > 0 || invites > 0) {
            cell.backgroundColor = MyLightestGray;
        } else {
            cell.backgroundColor = [UIColor whiteColor];
        }
        
        if([kamanDate isEarlierThan:[NSDate date]]) {
            [Utils setUIView:cell.button1 backgroundColor:[UIColor whiteColor] andRoundedByRadius:3 withBorderColor:MyGreyColor];
            [cell.button1 setTitleColor:MyGreyColor forState:UIControlStateNormal];
            
            [Utils setUIView:cell.button2 backgroundColor:[UIColor whiteColor] andRoundedByRadius:3 withBorderColor:MyGreyColor];
            [cell.button2 setTitleColor:MyGreyColor forState:UIControlStateNormal];
            [cell.editViewButton setTitleColor:MyGreyColor forState:UIControlStateNormal];
            
        } else {
            [Utils setUIView:cell.button1 backgroundColor:[UIColor whiteColor] andRoundedByRadius:3 withBorderColor:MyOrangeColor];
            [cell.button1 setTitleColor:MyOrangeColor forState:UIControlStateNormal];
            
            [Utils setUIView:cell.button2 backgroundColor:[UIColor whiteColor] andRoundedByRadius:3 withBorderColor:MyOrangeColor];
            [cell.button2 setTitleColor:MyOrangeColor forState:UIControlStateNormal];
            
            [cell.editViewButton setTitleColor:MyOrangeColor forState:UIControlStateNormal];
        }
        [Utils setUIView:cell.button3 backgroundColor:[UIColor whiteColor] andRoundedByRadius:3 withBorderColor:MyOrangeColor];
        [cell.button3 setTitleColor:MyOrangeColor forState:UIControlStateNormal];

        if(indexPath.section == 0) { // Invitations section
            
            NSInteger invitesCount =[Utils updateNotifBadgeFor:[NSString stringWithFormat: @"target = 'Attendee' AND type = '%@' AND kamanId = '%@'",PUSH_TYPE_INVITED,kaman.objectId] toView:nil position:MGBadgePositionBottomLeft];
            
            if(invitesCount > 0) {
                cell.backgroundColor = MyLightestGray;
            } else {
                cell.backgroundColor = [UIColor whiteColor];
            }
            
           
            [cell.editViewButton addTarget:self action:@selector(viewInvitedKamanAsAttendee:) forControlEvents:UIControlEventTouchUpInside];
            
            
            [cell.button1 addTarget:self action:@selector(acceptInvitation:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.button2 addTarget:self action:@selector(declineInvitation:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.button1 setTitle: @"Accept" forState:UIControlStateNormal];
            [cell.button2 setTitle: @"Decline" forState:UIControlStateNormal];
            

            [cell.button3 setAlpha:0.0]; // hide 3rd button
            
        } if(indexPath.section == 1) { // Accepted section
            
            [cell.button1 setTitle: @"Message Host" forState:UIControlStateNormal];
            [cell.button2 setTitle: @"Message Group" forState:UIControlStateNormal];
            [cell.button3 setTitle: @"Rate Host" forState:UIControlStateNormal];
            
            
            NSLog(@"Attendee private message [%@]: %lu",[kaman objectForKey:@"Name"],pmsgs);
            NSLog(@"Attendee Group message [%@]: %lu",[kaman objectForKey:@"Name"],groupChats);
            
            if(pmsgs > 0) {
                [cell.button1 setTitle: [NSString stringWithFormat: @"Message Host (%lu)", pmsgs] forState:UIControlStateNormal];
            } else {
                [cell.button1 setTitle: @"Message Host" forState:UIControlStateNormal];
            }
            
            if(groupChats > 0) {
                [cell.button2 setTitle: [NSString stringWithFormat: @"Msg Group (%lu)", groupChats] forState:UIControlStateNormal];
                
            } else {
                [cell.button2 setTitle: @"Message Group" forState:UIControlStateNormal];
            }
            
            [cell.editViewButton addTarget:self action:@selector(viewAcceptedKamanAsAttendee:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.button1 addTarget:self action:@selector(messageHostAcceptedKaman:) forControlEvents:UIControlEventTouchUpInside];
            [cell.button2 addTarget:self action:@selector(messageGroupAcceptedKaman:) forControlEvents:UIControlEventTouchUpInside];
            
            if([[NSDate date] isLaterThan:kamanDate]) { // accepted past
                [cell.button3 setTitleColor:MyOrangeColor forState:UIControlStateNormal];
                [cell.button3 addTarget:self action:@selector(attendeeRateHostAndAttendeePastKaman:) forControlEvents:UIControlEventTouchUpInside];
                [Utils setUIView:cell.button3 backgroundColor:[UIColor whiteColor] andRoundedByRadius:3 withBorderColor:MyOrangeColor];
                
            } else { // accepted upcoming
                [cell.button3 setTitleColor:MyGreyColor forState:UIControlStateNormal];
                [Utils setUIView:cell.button3 backgroundColor:[UIColor whiteColor] andRoundedByRadius:3 withBorderColor:MyGreyColor];
                // FIXME [Utils deleteNotifsWithQuery:[NSString stringWithFormat: @"kamanId = '%@'",kaman.objectId]];
            }
            [cell.button3 setAlpha:1.0];
        } else if(indexPath.section == 2) {  //awaiting host section
            [Utils setUIView:cell.button1 backgroundColor:[UIColor whiteColor] andRoundedByRadius:3 withBorderColor:MyGreyColor];
            
            [Utils setUIView:cell.button2 backgroundColor:[UIColor whiteColor] andRoundedByRadius:3 withBorderColor:MyGreyColor];
            
            [Utils setUIView:cell.button3 backgroundColor:[UIColor whiteColor] andRoundedByRadius:3 withBorderColor:MyGreyColor];
            
            [cell.editViewButton addTarget:self action:@selector(viewRequestedKamanAsAttendee:) forControlEvents:UIControlEventTouchUpInside];
            
            [cell.button1 setTitleColor:MyGreyColor forState:UIControlStateNormal];
            [cell.button2 setTitleColor:MyGreyColor forState:UIControlStateNormal];
            [cell.button3 setTitleColor:MyGreyColor forState:UIControlStateNormal];
            [cell.button3 setTitle: @"Rate Host" forState:UIControlStateNormal];
            [cell.button3 setAlpha:1.0];

        }
        
    }

    
        cell.editViewButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
        cell.kamanNameLabel.text = [kaman objectForKey:@"Name"];
        [Utils setUIView:cell.kamanImageView backgroundColor:[UIColor whiteColor] andRoundedByRadius:2  withBorderColor: MyGreyColor];
        cell.kamanImageView.image = [UIImage imageNamed:@"login-bg"];
        
        NSArray *kamanPhotos = [kamanPhotosDictionary objectForKey:kaman.objectId];
        if(!kamanPhotos || [kamanPhotos count] == 0) {
            // create a relation based on the authors key
            PFRelation *relation = [kaman relationForKey:@"Photos"];
            
            // generate a query based on that relation
            PFQuery *query = [relation query];
            [query orderByAscending:@"index"];
            [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                if(!error) {
                    [kamanPhotosDictionary setObject:objects forKey:kaman.objectId];
                    PFObject *photoObj = [objects firstObject];
                    PFFile *imageFile = [photoObj objectForKey:@"ImageFile"];
                    [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                        if (!error) {
                            UIImage *image = [UIImage imageWithData:data];
                            cell.kamanImageView.image = image;
                            // image can now be set on a UIImageView
                        } else {
                            NSLog(@"Error downloading first photo for %@: %@",[kaman objectForKey:@"Name"],error);
                        }
                    }];
                } else {
                    NSLog(@"Error fetching photos for %@: %@",[kaman objectForKey:@"Name"],error);
                }
            }];
        } else {
            PFObject *photoObj = [kamanPhotos firstObject];
            PFFile *imageFile = [photoObj objectForKey:@"ImageFile"];
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithData:data];
                    cell.kamanImageView.image = image;
                    // image can now be set on a UIImageView
                } else {
                    NSLog(@"Error downloading first photo for %@: %@",[kaman objectForKey:@"Name"],error);
                }
            }];
        }
    
        return cell;
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
