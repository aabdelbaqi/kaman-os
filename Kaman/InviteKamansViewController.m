//
//  InviteKamansViewController.m
//  Kaman
//
//  Created by Moin' Victor on 26/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import "InviteKamansViewController.h"
#import "PhotosKamanTableViewCell.h"
#import "DetailKamanTableViewCell.h"
#import "Utils.h"
#import "KamanActionButtonsView.h"
#import "Session.h"

#define NO_MORE  @"No more Kamaners to invite."

@interface InviteKamansViewController ()
@property (nonatomic) NSString * status;
@property (nonatomic) NSMutableArray * initialInvites;
@end

UIRefreshControl *kamanersRefreshControl;
@implementation InviteKamansViewController


- (IBAction)exit:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Utils setTitle:@"Invite Kamaners" withColor:MyOrangeColor andSubTitle:self.kaman != nil ? [self.kaman objectForKey:@"Name"] :@"Party" withColor:MyOrangeColor onNavigationController:self];
    
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
    PFQuery *query = [PFQuery queryWithClassName:@"KamanInvite"];
    [query whereKey:@"Kaman" equalTo:self.kaman];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error) {
            self.initialInvites = [NSMutableArray new];
            if([objects count] > 0) {
                for (PFObject * obj in objects) {
                    PFUser * invited = [obj objectForKey:@"InvitedUser"];
                    [self.initialInvites addObject:invited.objectId];
                }
            }
        }
        
        if(callback) {
            callback(nil);
        }
        
    }];

}


-(IBAction)searchKamaners:(id)sender
{
    self.status = @"Searching Kamaners...";
    [self.tableView reloadData];
    [kamanersRefreshControl beginRefreshing];
    
    PFQuery *query = [PFUser query];
    if(self.initialInvites) {
        [query whereKey:@"objectId" notContainedIn:self.initialInvites];
    }
    [query whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId]; // exclude current user
    if(DEV_MODE == 0) {
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



-(void) doInviteFriend
{
    PFUser *kamaner = [self.users firstObject];
    
    PFRelation *relation = [self.kaman relationForKey:@"Invitations"];
    
    PFObject *kamanRequest = [PFObject objectWithClassName:@"KamanInvite"];
    [kamanRequest setObject:kamaner forKey:@"InvitedUser"];
    [kamanRequest setObject:self.kaman forKey:@"Kaman"];
    [kamanRequest setObject:[NSNumber numberWithBool:NO] forKey:@"Accepted"];
    [kamanRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        
        if (!error) {
            [relation addObject:kamanRequest];
            
            [self.kaman saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(!error) {
                    [kamaner addUniqueObjectsFromArray:[NSArray arrayWithObject:self.kaman.objectId] forKey:@"InvitedKamans"];
                    [kamaner saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if(error) {
                            [kamaner saveEventually];
                            NSLog(@"Error saving user liked kaman: %@",error.localizedDescription);
                        }
                    }];
                    [self.initialInvites addObject:kamaner.objectId];
                    
                    if([kamaner notifyInvites]) {
                        [Utils sendPushFor:PUSH_TYPE_INVITED toUser:kamaner withMessage:[NSString stringWithFormat: @"You have been invited to attend '%@'. Looks like it's happening.",[self.kaman objectForKey:@"Name"]] ForKaman:self.kaman];
                    }
                } else {
                    NSLog(@"Error making Kaman Invite: %@",error.localizedDescription);
                    [self.kaman saveEventually];
                    [self.initialInvites addObject:kamaner.objectId];
                    
                }
            }];
            
        } else {
            [Utils showMessageHUDInView:self.view withMessage:error.localizedDescription afterError:YES];
        }
        
    }];
    
    
}

-(void) inviteFriend
{
    
    PFObject *kamaner = [self.users firstObject];
    
    if (self.initialInvites) {
        if([self.initialInvites containsObject:kamaner.objectId]) {
            [TSMessage showNotificationWithTitle:[self.kaman objectForKey:@"Name"] subtitle:@"You already invited this Kamaner" type:TSMessageNotificationTypeWarning];
        } else {
            NSArray * liked = [kamaner objectForKey:@"LikedKamans"];
            if(![liked containsObject:self.kaman.objectId]) { // only if user has not liked it already
                [self doInviteFriend];
            }
        }
        
        
        [self.users removeObjectAtIndex:0];
        [self.tableView reloadData];
        
        return;
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"KamanInvite"];
    [query whereKey:@"Kaman" equalTo:self.kaman];
    [query includeKey:@"InvitedUser"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if(!error) {
            self.initialInvites = [NSMutableArray new];
            if([objects count] > 0) {
                for (PFObject * obj in objects) {
                    PFUser * invited = [obj objectForKey:@"InvitedUser"];
                    [self.initialInvites addObject:invited.objectId];
                }
            }
            if([self.initialInvites containsObject:kamaner.objectId]) {
                [TSMessage showNotificationWithTitle:[self.kaman objectForKey:@"Name"] subtitle:@"You already invited this Kamaner" type:TSMessageNotificationTypeWarning];
            } else {
                NSArray * liked = [kamaner objectForKey:@"LikedKamans"];
                if(![liked containsObject:self.kaman.objectId]) { // only if user has not liked it already
                    [self doInviteFriend];
                }
            }
        } else {
            [Utils showMessageHUDInView:self.view withMessage:error.localizedDescription afterError:YES];
        }
        
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
