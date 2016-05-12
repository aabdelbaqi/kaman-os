//
//  PickChatUserTableViewController.m
//  Kaman
//
//  Created by Moin' Victor on 02/12/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import "PickChatUserTableViewController.h"
#import "MessagesViewController.h"
#import "Utils.h"
#import "RateUserTableViewCell.h"
#import "LocalNotif.h"

@interface PickChatUserTableViewController ()
@property NSMutableArray *users;
@end

@implementation PickChatUserTableViewController

- (IBAction)exit:(id)sender {
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar setBarTintColor:
     [UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:MyOrangeColor}];
    [self.navigationController.navigationItem.leftBarButtonItem setTintColor:MyOrangeColor];
    self.view.backgroundColor = MyBrownColor;
    
    self.users = [NSMutableArray new];

    // Uncomment the following line to preserve selection between presentations.
     self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(exit:)];
    [self.navigationItem.leftBarButtonItem setTintColor:MyOrangeColor];
    
     self.tableView.tableFooterView = [UIView new];
     self.tableView.showsVerticalScrollIndicator = NO;
    
    
    UINib *detailNib = [UINib nibWithNibName:@"RateUserTableViewCell" bundle:nil];
    [[self tableView] registerNib:detailNib forCellReuseIdentifier:@"Cell"];
    
     [Utils setTitle:@"New Private Message" withColor:MyOrangeColor andSubTitle:@"Select Attendee" withColor:MyOrangeColor onNavigationController:self];
    [self searchAll];
    
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

-(void)searchAll
{
    [self searchKamanInvitedAttendees];
    [self searchKamanRequestedAttendees];
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
                if(![self.users containsObject:user] && [user isVisibileToOtherKamans]) {
                    [self.users addObject:user];
                }
            }
        }
        [self.tableView reloadData];
        
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
                if(![self.users containsObject:user] && [user isVisibileToOtherKamans]) {
                    [self.users addObject:user];
                }

            }
        }
        [self.tableView reloadData];
        
    }];
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
        
        
        NSString *text = @"No Users are attending this Kaman yet";
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
    
    RLMResults *notifs = [LocalNotif objectsWhere:
                          [NSString stringWithFormat: @"kamanId = '%@' AND type = '%@' AND senderId = '%@'",self.kaman.objectId,PUSH_TYPE_CHAT_MESSAGE, kamanUser.objectId]];
    
    cell.rate0Btn.badgeView.badgeValue = [notifs count];
    cell.rate0Btn.badgeView.badgeColor = DesignersBrownColor;
    cell.rate0Btn.badgeView.textColor = [UIColor blackColor];
    cell.rate0Btn.badgeView.position = MGBadgePositionCenterRight;
    [cell.rate0Btn.badgeView setOutlineWidth:2.0];
    [cell.rate0Btn.badgeView setOutlineColor:MyGreyColor];
    
    [cell.userNameLabel setText:[kamanUser displayName]];
    [Utils setUIView:cell.userImageView backgroundColor:MyGreyColor andRoundedByRadius:cell.userImageView.frame.size.height/2 withBorderColor:[UIColor whiteColor]];

    if([kamanUser profileImageURL]) {
        
        cell.userImageView.contentMode = UIViewContentModeScaleAspectFill;
        [cell.userImageView sd_setImageWithURL:[NSURL URLWithString:[kamanUser profileImageURL]]
               placeholderImage:[UIImage imageNamed:@"person"]
                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                      }];
    }
    [cell.rate0Btn setAlpha:1.0];
    cell.rate0Btn.tintColor = cell.backgroundColor;
    [cell.rate1Btn setAlpha:0.0];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RateUserTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    PFUser * kamanUser =  [self.users objectAtIndex:indexPath.row];
    if([self.pickChatUserDelegate respondsToSelector:@selector(didSelectAttendee:withAvatar:forKaman:)]) {
        [self.pickChatUserDelegate didSelectAttendee:kamanUser withAvatar:cell.userImageView.image forKaman:self.kaman];
    }
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
