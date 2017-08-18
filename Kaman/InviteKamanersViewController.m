//
//  InviteKamansViewController.m
//  Kaman
//
//  Created by Moin' Victor on 26/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import "InviteKamanersViewController.h"
#import "PhotosKamanTableViewCell.h"
#import "DetailKamanTableViewCell.h"
#import "Utils.h"
#import "KamanActionButtonsView.h"
#import "Session.h"

#define NO_MORE  @"No more Kamaners to invite."

@interface InviteKamanersViewController ()
@property (nonatomic) NSString * status;
@property BOOL devMode;
@property (nonatomic) NSMutableArray * initialInvitedAndRequesters;
@end

UIRefreshControl *kamanersRefreshControl;
@implementation InviteKamanersViewController

- (IBAction)exit:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        if(config) {
            NSNumber *devModeNSNumber = [config objectForKey: @"DevMode"];
            _devMode = [devModeNSNumber boolValue];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Utils setTitle:@"Invite Kamaners" withColor:MyOrangeColor andSubTitle:self.kamanObject != nil ? [self.kamanObject objectForKey:@"Name"] :@"Party" withColor:MyOrangeColor onNavigationController:self];
    
    kamanersRefreshControl = [[UIRefreshControl alloc]init];
  //  [self.tableView addSubview:kamanersRefreshControl];
    [kamanersRefreshControl addTarget:self action:@selector(searchKamaners:) forControlEvents:UIControlEventValueChanged];

    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
    
    [self initInitialInvitesThen:^(id result) {
        [self searchKamaners:nil];
    }];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.showButtons = YES;
    self.headerPannable = YES;
}

-(void) initInitialInvitesThen:(ResultCallback) callback
{
    
    [Utils invitesAndRequestsForKaman:self.kamanObject onSuccess:^(NSArray *invites, NSArray *requests) {
        self.initialInvitedAndRequesters = [NSMutableArray new];
        
        for (NSString* request in requests)  {
            [self.initialInvitedAndRequesters addObject:request];
        }
        
        for (NSString* invite in invites)  {
            [self.initialInvitedAndRequesters addObject:invite];
        }
        
        if(callback) {
            callback(self.initialInvitedAndRequesters);
        }
        
    } onError:^(NSError *error) {
        if(callback) {
            callback(self.initialInvitedAndRequesters);
        }
    }];
}


-(IBAction)searchKamaners:(id)sender
{
    self.status = @"Searching Kamaners...";
    [self.tableView reloadData];
    [kamanersRefreshControl beginRefreshing];
    
    PFQuery *query = [PFUser query];
    if(self.initialInvitedAndRequesters) {
        [query whereKey:@"objectId" notContainedIn:self.initialInvitedAndRequesters];
    }
    [query whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId]; // exclude current user
    if(self.devMode ==  false) {
         // Interested in locations near user.
        [query whereKey:@"LastKnownLocation" nearGeoPoint:[PFGeoPoint geoPointWithLatitude:currentLocality.lat longitude:currentLocality.lon] withinKilometers:[[PFUser currentUser] discoveryPerimeter].intValue];
    }
    [query whereKey:@"Visibility" equalTo:[NSNumber numberWithBool:YES]];
    // TODO maybe also filter countries e.t.c
    // [query whereKey:@"Area" equalTo:obj];
    // Limit what could be a lot of points.
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [kamanersRefreshControl endRefreshing];
        if(!error) {
            if([objects count] > 0) {
                [self.users removeAllObjects];
                [self.users addObjectsFromArray:objects];
            }
        }
        self.status= NO_MORE;
        [self.tableView reloadData];
        
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void) doInviteFriend:(PFUser*) kamaner
{
    if(!kamaner) {
        return;
    }
    [kamaner inviteToKaman:self.kamanObject onCallBack:^(id result) {
        PFObject *invite = result;
         NSLog(@"%@ invited with ID: ",invite.objectId);
        if([kamaner notifyInvites]) {
            [Utils sendPushFor:PUSH_TYPE_INVITED toUser:kamaner withMessage:[NSString stringWithFormat: @"You have been invited to attend '%@'. Looks like it's happening.",[self.kamanObject objectForKey:@"Name"]] ForKaman:self.kamanObject];
        }
    } onError:^(NSError *error) {
         [Utils showStatusNotificationWithMessage:[NSString stringWithFormat:@"Error: %@ ", error.localizedDescription] isError:YES];
    }];
}

-(void) inviteFriend
{
    
    PFUser *kamaner = [self.users firstObject];
    [kamaner hasBeenInvitedOrHasRequestedToAttendKaman:self.kamanObject onCallBack:^(BOOL result) {
        if (result) {
            NSLog(@"%@ has already been invited.",[kamaner displayName]);
             [Utils showStatusNotificationWithMessage:[NSString stringWithFormat:@"%@ already requested or been invited to attend this Kaman",[kamaner displayName]] isError:NO];
        }else {
            NSLog(@"%@ has not been invited.",[kamaner displayName]);
            [self doInviteFriend:kamaner];
        }
        
    } onError:^(NSError *error) {
        [Utils showStatusNotificationWithMessage:[NSString stringWithFormat:@"Error: %@ ", error.localizedDescription] isError:YES];
    }];

    [self.users removeObjectAtIndex:0];
    [self.tableView reloadData];
    
    
}

-(void) dismissKamaner
{
    PFUser *kamaner = [self.users firstObject];
    
    [self.users removeObjectAtIndex:0];
    [self.tableView reloadData];
}

-(void)acceptClicked
{
    [super acceptClicked];
    [self inviteFriend];
}

-(void)declineClicked
{
    [super declineClicked];
    [self dismissKamaner];
}

#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self.users count] > 0) {
        
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
        
    } else {
        
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        
        NSString *text = self.status;
        
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
