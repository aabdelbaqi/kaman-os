//
//  KamanRequestsTableViewController.m
//  Kaman
//
//  Created by Moin' Victor on 30/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import "KamanRequestsTableViewController.h"
#import "KamanNotificationTableViewCell.h"
#import "PFUser+Kamaner.h"
#import "KamanLocalNotif.h"
#import "Utils.h"
#import "UserProfileViewController.h"

@interface KamanRequestsTableViewController ()

@end

UIRefreshControl *kamanReqsRefreshControl;

@implementation KamanRequestsTableViewController

- (IBAction)exit:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [Utils setTitle:[NSString stringWithFormat: @"Requests (%lu)", (unsigned long)[self.kamanRequests count]] withColor:MyOrangeColor andSubTitle:self.kaman != nil ? [self.kaman objectForKey:@"Name"] :@"Party" withColor:MyOrangeColor onNavigationController:self];
    
    self.view.backgroundColor = MyBrownColor;
    self.tableView.backgroundColor = MyBrownColor;
    
    UINib *badicNib = [UINib nibWithNibName:@"KamanNotificationTableViewCell" bundle:nil];
    [[self tableView] registerNib:badicNib forCellReuseIdentifier:@"NotifCell"];
    
    [self.tableView setSeparatorColor:MyDarkGrayColor];
    
    // This will remove extra separators from tableview
    self.tableView.tableFooterView = [UIView new];
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    self.tableView.allowsSelection = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    [self.navigationController.navigationBar setBarTintColor:
     [UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:MyOrangeColor}];
    
    
    kamanReqsRefreshControl = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:kamanReqsRefreshControl];
    [kamanReqsRefreshControl addTarget:self action:@selector(searchKamanRequests:) forControlEvents:UIControlEventValueChanged];
    
    // Uncomment the following line to preserve selection between presentations.
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self searchKamanRequests:nil];
}

-(IBAction)searchKamanRequests:(id)sender
{
    [self.tableView reloadData];
     [kamanReqsRefreshControl beginRefreshing];
    PFRelation *relation = [self.kaman relationForKey:@"Requests"];
    
    // generate a query based on that relation
    PFQuery *query = [relation query];
    [query includeKey:@"RequestingUser"];
    [query includeKey:@"Kaman"];
    [query includeKey:@"Kaman.Area"];
    [query includeKey:@"Kaman.Host"];
    [query whereKey:@"Accepted" notEqualTo:[NSNumber numberWithBool:YES]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        [kamanReqsRefreshControl endRefreshing];
        if(!error) {
            if([objects count] > 0) {
                [self.kamanRequests removeAllObjects];
                [self.kamanRequests addObjectsFromArray:objects];
                [Utils deleteNotifsWithQuery:[NSString stringWithFormat: @"kamanId = '%@' AND type = '%@'",self.kaman.objectId,PUSH_TYPE_REQUESTED]];
            }
        }
        [Utils setTitle:[NSString stringWithFormat: @"Requests (%lu)", (unsigned long)[self.kamanRequests count]] withColor:MyOrangeColor andSubTitle:self.kaman != nil ? [self.kaman objectForKey:@"Name"] :@"Party" withColor:MyOrangeColor onNavigationController:self];
        
        [self.tableView reloadData];
        
    }];
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

-(void) acceptRequest:(id) sender
{
    UIButton * btn = sender;
    
    PFObject *kamanReq = [self.kamanRequests objectAtIndex:btn.tag];
    PFUser *requestingUser =  [kamanReq objectForKey:@"RequestingUser"];
    
    [kamanReq setObject:[NSNumber numberWithBool:YES] forKey:@"Accepted"];
    [kamanReq saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error) {
            [self.kamanRequests removeObject:kamanReq];
            [Utils setTitle:[NSString stringWithFormat: @"Requests (%lu)", [self.kamanRequests count]] withColor:MyOrangeColor andSubTitle:self.kaman != nil ? [self.kaman objectForKey:@"Name"] :@"Party" withColor:MyOrangeColor onNavigationController:self];
            
            /*[requestingUser addUniqueObjectsFromArray:[NSArray arrayWithObject:self.kaman.objectId] forKey:@"KamansAttended"];
            [requestingUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if(error) {
                    [requestingUser saveEventually];
                    NSLog(@"Error updating KamansAttended Invite: %@",error.localizedDescription);
                }
            }];*/
            if([requestingUser notifyRequests]) {
                [Utils sendPushFor:PUSH_TYPE_REQUEST_ACCEPTED toUser:requestingUser withMessage:[NSString stringWithFormat: @"Congratulations! Your request to attend '%@' is accepted. You can now see the address of the event.",[self.kaman objectForKey:@"Name"]] ForKaman:self.kaman];
            }
            [self.tableView reloadData];
        } else {
            [Utils showMessageHUDInView:self.view withMessage:[error localizedDescription] afterError:YES];
        }
    }];
    
}




-(void) declineRequest: (id) sender
{
    UIButton * btn = sender;
   
    PFObject *kamanReq = [self.kamanRequests objectAtIndex:btn.tag];
    [kamanReq deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error) {
            [Utils showMessageHUDInView:self.view withMessage:@"Request Declined!" afterError:NO];
            [self.kamanRequests removeObject:kamanReq];
            [Utils setTitle:[NSString stringWithFormat: @"Requests (%lu)", [self.kamanRequests count]] withColor:MyOrangeColor andSubTitle:self.kaman != nil ? [self.kaman objectForKey:@"Name"] :@"Party" withColor:MyOrangeColor onNavigationController:self];
            
            [self.tableView reloadData];
        } else {
            [Utils showMessageHUDInView:self.view withMessage:[error localizedDescription] afterError:YES];
        }
    }];
    
}


-(void) kamanNameTapped: (UITapGestureRecognizer*) sender
{
    UILabel * labelView = (UILabel*)sender.view;
    PFObject *kamanReq = [self.kamanRequests objectAtIndex:labelView.tag];
    
    PFUser *requestingUser = [kamanReq objectForKey:@"RequestingUser"];
    
    [self takeToProfleFor:requestingUser isHost:NO];
}


-(void) takeToProfleFor:(PFUser*) user isHost: (BOOL)isHost
{
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    UserProfileViewController *someViewController = [storyboard instantiateViewControllerWithIdentifier:@"user_profile"];
    someViewController.users = [NSMutableArray arrayWithObject:user];
    someViewController.kamanObject = self.kaman;
    
    [Utils setTitle:isHost ? @"Host Profile" : @"Requesting Attendee Profile" withColor:MyOrangeColor andSubTitle:self.kaman != nil ? [self.kaman objectForKey:@"Name"] :@"Party" withColor:MyOrangeColor onNavigationController:someViewController];
    
    [self.navigationController pushViewController:someViewController animated:YES];
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
    // Return the number of sections.
    if ([self.kamanRequests count] > 0) {
        
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
        
    } else {
        
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        
        NSString *text = @"No Users have requested to attend this Kaman yet. Pull to refresh";
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
  return [self.kamanRequests count];
}


-(CGFloat) calculateHeight
{
    if(IS_IPHONE_6 || IS_IPHONE_5) {
        return 100;
    }
    return self.tableView.frame.size.width - (70*3) - 30;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self calculateHeight];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    PFObject *kamanReq = [self.kamanRequests objectAtIndex:indexPath.row];
    
    PFUser *requestingUser = [kamanReq objectForKey:@"RequestingUser"];
    [requestingUser fetchIfNeededInBackground];

    
    KamanNotificationTableViewCell *cell =  [tableView dequeueReusableCellWithIdentifier:@"NotifCell"];
    cell.backgroundColor = MyBrownColor;
    cell.kamanNameLabel.tag = indexPath.row;
    
    [cell.kamanImageView setUserInteractionEnabled:YES];
    cell.imageViewHeightConstraint.constant = (IS_IPHONE_6 || IS_IPHONE_5 ? 72.0 : [self calculateHeight] -  20);
    cell.imageViewWidthConstraint.constant = (IS_IPHONE_6 || IS_IPHONE_5 ? 72.0 : [self calculateHeight] -  20);
    [cell setNeedsDisplay];
    cell.editViewButton.tag = indexPath.row;
    cell.editViewButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    [Utils setUIView:cell.kamanImageView backgroundColor:[UIColor whiteColor] andRoundedByRadius:2  withBorderColor: MyGreyColor];
    
    [Utils setUIView:cell.button1 backgroundColor:cell.backgroundColor andRoundedByRadius:3 withBorderColor:WhatsappGreenColor];
    [Utils setUIView:cell.button2 backgroundColor:cell.backgroundColor andRoundedByRadius:3 withBorderColor:MyOrangeColor];
    [Utils setUIView:cell.button3 backgroundColor:cell.backgroundColor andRoundedByRadius:3 withBorderColor:MyOrangeColor];
    
    [cell.editViewButton removeTarget:nil
                               action:NULL
                     forControlEvents:UIControlEventAllEvents];
    [cell.editViewButton setTitle:@"Wants to attend your party" forState:UIControlStateNormal];
    
    [cell.button1 removeTarget:nil
                        action:NULL
              forControlEvents:UIControlEventAllEvents];
    [cell.button1 addTarget:self action:@selector(acceptRequest:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.button2 removeTarget:nil
                        action:NULL
              forControlEvents:UIControlEventAllEvents];
    [cell.button2 addTarget:self action:@selector(declineRequest:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.button1 setTitle: @"Accept" forState:UIControlStateNormal];
    [cell.button2 setTitle: @"Decline" forState:UIControlStateNormal];
    
    [cell.button3 setTitleColor:MyOrangeColor forState:UIControlStateNormal];
    
    [cell.editViewButton setTitleColor:MyDarkGrayColor forState:UIControlStateNormal];
    
    [cell.button1 setTitleColor:WhatsappGreenColor forState:UIControlStateNormal];
    [cell.button2 setTitleColor:MyOrangeColor forState:UIControlStateNormal];
    [cell.button3 setAlpha:0.0]; // hide 3rd button

    cell.kamanImageView.image = [UIImage imageNamed:@"login-bg"];
    
    // NSString * age = [Utils getPFUserAgeAsString:requestingUser onNoAge:@"<Age Hidden>"];
    UITapGestureRecognizer *singleProfileTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(kamanNameTapped:)];
    singleProfileTap.numberOfTapsRequired = 1;
    [cell.kamanNameLabel setUserInteractionEnabled:YES];
    [cell.kamanNameLabel addGestureRecognizer:singleProfileTap];
    [cell.kamanNameLabel setText:[requestingUser displayName]];
     //[@"<Age Hidden>" isEqualToString:age ] ? name :[NSString stringWithFormat:@"%@, %@",name,age]];
    
    if([requestingUser profileImageURL]) {
        [cell.kamanImageView  sd_setImageWithURL:[NSURL URLWithString:[requestingUser profileImageURL]]
                                placeholderImage:[UIImage imageNamed:@"login-bg"]
                                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                           
                                           
                                       }];
    } else {
        [cell.kamanImageView setImage:[UIImage imageNamed:@"login-bg"]];
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
