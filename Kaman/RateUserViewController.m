//
//  RateUserViewController.m
//  Kaman
//
//  Created by Moin' Victor on 04/12/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import "RateUserViewController.h"
#import "RateUserTableViewCell.h"

@interface RateUserViewController ()
@property (nonatomic) UIRefreshControl *myrefreshControl;
@property (nonatomic) NSMutableDictionary * myRates;
@property (nonatomic) NSMutableDictionary * userRateObjects;
@end

@implementation RateUserViewController

- (IBAction)exit:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) sendGoogleAnalyticsTrackScreen
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Rate screen"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self sendGoogleAnalyticsTrackScreen];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBarTintColor:
     [UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:MyOrangeColor}];
    [self.navigationController.navigationItem.leftBarButtonItem setTintColor:MyOrangeColor];
    self.view.backgroundColor = MyBrownColor;
    
    UINib *detailNib = [UINib nibWithNibName:@"RateUserTableViewCell" bundle:nil];
    [[self tableView] registerNib:detailNib forCellReuseIdentifier:@"Cell"];
    
    [self.tableView setSeparatorColor:MyDarkGrayColor];
    
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [UIView new];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.allowsSelection = NO;

    if(!self.users) {
        self.users = [NSMutableArray new];
    }
    self.myRates = [NSMutableDictionary new];
    self.userRateObjects = [NSMutableDictionary new];

    
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.allowsSelection = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if(self.ratingHost != YES) {
        [self searchAll];
    }
    
    self.myrefreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:self.myrefreshControl];
    [self.myrefreshControl addTarget:self action:@selector(searchAll) forControlEvents:UIControlEventValueChanged];

}


-(void)viewDidLayoutSubviews
{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(void)searchAll
{
    [self.refreshControl beginRefreshing];
    [self searchKamanInvitedAttendees];
    [self searchKamanRequestedAttendees];
}

-(void) fetchMyRatingsFor:(NSArray*)users
{
    PFQuery *query = [PFQuery queryWithClassName:@"KamanerRating"];
    [query whereKey:@"RatedBy" equalTo:[PFUser currentUser]];
    [query whereKey:@"RatedFor" containedIn:users];
    [query includeKey:@"RatedFor"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error) {
            for (PFObject * obj in objects) {
                PFUser * user = [obj objectForKey:@"RatedFor"];
                [self.myRates setObject:(NSNumber*)[obj objectForKey:@"IsPartyAnimal"] forKey:user.objectId];
                [self.userRateObjects setObject:obj forKey:user.objectId];
            }
            [self.tableView reloadData];
            NSLog(@"My Ratings: %@",self.myRates);
        }
    }];
}

-(void)searchKamanRequestedAttendees
{
    [self.tableView reloadData];
    PFRelation *relation = [self.kaman relationForKey:@"Requests"];
    
    // generate a query based on that relation
    PFQuery *query = [relation query];
    [query includeKey:@"RequestingUser"];
    [query whereKey:@"RequestingUser" notEqualTo:[PFUser currentUser]];
    [query whereKey:@"Accepted" equalTo:[NSNumber numberWithBool:YES]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error) {
            for (PFObject * obj in objects) {
                PFUser * user = [obj objectForKey:@"RequestingUser"];
                if(![self.users containsObject:user]) {
                    [self.users addObject:user];
                }
            }
           
        }
        [self fetchMyRatingsFor:self.users];
        [self.tableView reloadData];
        [self.myrefreshControl endRefreshing];
    }];
}

-(void)searchKamanInvitedAttendees
{
    [self.tableView reloadData];
    PFRelation *relation = [self.kaman relationForKey:@"Invitations"];
    
    // generate a query based on that relation
    PFQuery *query = [relation query];
    [query includeKey:@"InvitedUser"];
    [query whereKey:@"InvitedUser" notEqualTo:[PFUser currentUser]];
    [query whereKey:@"Accepted" equalTo:[NSNumber numberWithBool:YES]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error) {
            for (PFObject * obj in objects) {
                PFUser * user = [obj objectForKey:@"InvitedUser"];
                if(![self.users containsObject:user]) {
                    [self.users addObject:user];
                }
                
            }
        }
        [self fetchMyRatingsFor:self.users];
        [self.tableView reloadData];
        [self.myrefreshControl endRefreshing];
    }];
}


-(void) rateIsPartyAnimal:(id) sender
{
    UIButton * btn = sender;
    PFUser * kamanUser =  [self.users objectAtIndex:btn.tag];
    
    PFObject * newRate = [self.userRateObjects objectForKey:kamanUser.objectId];
    
    if(newRate == nil)
        newRate = [PFObject objectWithClassName:@"KamanerRating"];
    
    [newRate setObject:[PFUser currentUser] forKey:@"RatedBy"];
    [newRate setObject:kamanUser forKey:@"RatedFor"];
    [newRate setObject:[NSNumber numberWithBool:YES] forKey:@"IsPartyAnimal"];
    [newRate saveEventually:^(BOOL succeeded, NSError * _Nullable error) {
        // only notify ratings for first time only
        if(succeeded && [[newRate createdAt] isEqualToDate:[newRate updatedAt]]) {
            if([kamanUser notifyRatings]) {
                NSString * hostOrAttendee = [kamanUser.objectId isEqualToString:[[self.kaman objectForKey:@"Host"] objectForKey: @"objectId"]] ? @"a host" : @"an attendee";
                                           
                [Utils sendPushFor:PUSH_TYPE_RATED toUser:kamanUser withMessage: [NSString stringWithFormat:@"Someone rated you as %@ of '%@'. Go to you profile to see the rating",hostOrAttendee,[self.kaman objectForKey:@"Name"]] ForKaman:self.kaman];
            }
            
        }
    }];
    [self.myRates setObject:[NSNumber numberWithBool:YES] forKey:kamanUser.objectId];
    [self.userRateObjects setObject:newRate forKey:kamanUser.objectId];
    [self.tableView reloadData];
    
}

-(void) rateIsNotPartyAnimal:(id) sender
{
    
    UIButton * btn = sender;
    PFUser * kamanUser =  [self.users objectAtIndex:btn.tag];
    
    PFObject * newRate = [self.userRateObjects objectForKey:kamanUser.objectId];
    
    if(newRate != nil && [(NSNumber*)[self.myRates objectForKey:kamanUser.objectId ] boolValue] == NO) {
        [newRate deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            
        }];
        [self.myRates removeObjectForKey:kamanUser.objectId];
        [self.userRateObjects removeObjectForKey:kamanUser.objectId];
    } else {
        if(newRate == nil)
            newRate = [PFObject objectWithClassName:@"KamanerRating"];
        [newRate setObject:[PFUser currentUser] forKey:@"RatedBy"];
        [newRate setObject:kamanUser forKey:@"RatedFor"];
        [newRate setObject:[NSNumber numberWithBool:NO] forKey:@"IsPartyAnimal"];
        [newRate saveEventually:^(BOOL succeeded, NSError * _Nullable error) {
            // only notify ratings for first time only
            if(succeeded && [[newRate createdAt] isEqualToDate:[newRate updatedAt]]) {
                if([kamanUser notifyRatings]) {
                    [Utils sendPushFor:PUSH_TYPE_RATED toUser:kamanUser withMessage: [NSString stringWithFormat:@"%@ has rated you.Your current ratings can be seen in your profile.",[[PFUser currentUser] displayName]] ForKaman:self.kaman];
                }
                
            }
        }];
        [self.myRates setObject:[NSNumber numberWithBool:NO] forKey:kamanUser.objectId];
        [self.userRateObjects setObject:newRate forKey:kamanUser.objectId];
    }
    [self.tableView reloadData];
    
}

#pragma mark - Table view data source

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.users count] > 0) {
        
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
        
    } else {
        
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        
        NSString *text = @"No users attended this Kaman.";
        messageLabel.text = text;
        messageLabel.textColor = MyOrangeColor;
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font =  [UIFont systemFontOfSize:14];
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }
    
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.users  count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RateUserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    PFUser * kamanUser =  [self.users objectAtIndex:indexPath.row];
    [cell.userNameLabel setText:[kamanUser displayName]];
    cell.rate0Btn.tag = indexPath.row;
    cell.rate1Btn.tag = indexPath.row;
    
    [cell.rate0Btn removeTarget:nil
                        action:NULL
              forControlEvents:UIControlEventAllEvents];
    [cell.rate1Btn removeTarget:nil
                        action:NULL
              forControlEvents:UIControlEventAllEvents];
    [cell.rate0Btn addTarget:self action:@selector(rateIsNotPartyAnimal:) forControlEvents:UIControlEventTouchUpInside];
    [cell.rate1Btn addTarget:self action:@selector(rateIsPartyAnimal:) forControlEvents:UIControlEventTouchUpInside];
    
    NSNumber *rate = [self.myRates objectForKey:kamanUser.objectId];
    if(rate) {
        BOOL partyAnimal = [rate boolValue];
        if(partyAnimal == YES) {
            cell.rate0Btn.tintColor = MyGreyColor;
            cell.rate1Btn.tintColor = [UIColor blackColor];
        } else {
            cell.rate0Btn.tintColor = [UIColor blackColor];
            cell.rate1Btn.tintColor = MyGreyColor;
        }
    } else {
        cell.rate0Btn.tintColor = MyGreyColor;
        cell.rate1Btn.tintColor = MyGreyColor;
    }
    [Utils setUIView:cell.userImageView backgroundColor:MyGreyColor andRoundedByRadius:cell.userImageView.frame.size.height/2 withBorderColor:[UIColor whiteColor]];
    
    if([kamanUser profileImageURL]) {
        
        cell.userImageView.contentMode = UIViewContentModeScaleAspectFill;
        [cell.userImageView sd_setImageWithURL:[NSURL URLWithString:[kamanUser profileImageURL]]
                          placeholderImage:[UIImage imageNamed:@"person"]
                                 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 }];
    }
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
