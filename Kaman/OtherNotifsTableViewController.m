//
//  OtherNotifsTableViewController.m
//  Kaman
//
//  Created by Moin' Victor on 31/03/2016.
//  Copyright © 2016 Riad & Co. All rights reserved.
//

#import "OtherNotifsTableViewController.h"
#import "Utils.h"
#import "KamanLocalNotif.h"
#import <DateTools/DateTools.h>
#import "OtherNotifsTableViewCell.h"

@interface OtherNotifsTableViewController ()

@end

@implementation OtherNotifsTableViewController
NSMutableArray * otherNotifs;

-(IBAction)exit:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBarTintColor:
     [UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:MyOrangeColor}];
    
    self.view.backgroundColor = MyBrownColor;
    
    UIImage *img = [UIImage imageNamed:@"notifications"];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    [imgView setImage:img];
    // setContent mode aspect fit
    [imgView setContentMode:UIViewContentModeScaleAspectFit];
    self.navigationItem.titleView = imgView;
    
    
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc]
                                  initWithTitle:@"Close"
                                  style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(exit:)];
    [cancelBtn setTintColor:MyOrangeColor];
    self.navigationItem.leftBarButtonItem = cancelBtn;
    
    otherNotifs = [NSMutableArray new];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    RLMResults<KamanLocalNotif *> *targetNotifs = [KamanLocalNotif objectsWhere:[NSString stringWithFormat:@"type IN {'%@','%@','%@'}",PUSH_TYPE_REQUEST_ACCEPTED, PUSH_TYPE_INVITE_ACCEPTED,PUSH_TYPE_RATED]];
    for (KamanLocalNotif * notif in targetNotifs) {
            [otherNotifs addObject:notif];
    }

    UINib *badicNib = [UINib nibWithNibName:@"OtherNotifsTableViewCell" bundle:nil];
    [[self tableView] registerNib:badicNib forCellReuseIdentifier:@"Cell"];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 150;
    
    // remove extra cells
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [otherNotifs count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OtherNotifsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    UIFont  * font = [UIFont systemFontOfSize:13.0];
    KamanLocalNotif * notif = [otherNotifs objectAtIndex:indexPath.row];
    NSString * query = [NSString stringWithFormat:@"kamanId = '%@' AND type = '%@'", notif.kamanId ,notif.type];
    [cell.titleLabel setText:notif.data];
    [cell.titleLabel setFont:font];
    RLMResults<KamanLocalNotif *> *notifs = [KamanLocalNotif objectsWhere:query];
    if([notifs count] == 0) {
        [cell.titleLabel setTextColor:[UIColor blackColor]];
    } else {
        [cell.titleLabel setTextColor:[UIColor blackColor]];
        [UIView transitionWithView:cell.titleLabel duration:0.25 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            [cell.titleLabel setTextColor:[UIColor blackColor]];
        } completion:^(BOOL finished) {
            [Utils deleteNotifsWithQuery:query];
        }];
    }
    [cell.subtitleLabel setText:[notif.date timeAgoSinceNow]];
    [cell.subtitleLabel setFont:[UIFont systemFontOfSize:11.0]];
    
    //Calculate the expected size based on the font and linebreak mode of your label
    // FLT_MAX here simply means no constraint in height
    CGSize maximumLabelSize = CGSizeMake(296, FLT_MAX);
    
    CGSize expectedLabelSize = [notif.data sizeWithFont:font constrainedToSize:maximumLabelSize lineBreakMode:cell.titleLabel.lineBreakMode];
    
    //adjust the label the the new height.
    CGRect newFrame = cell.textLabel.frame;
    newFrame.size.height = expectedLabelSize.height;
    cell.titleLabel.frame = newFrame;
    cell.preservesSuperviewLayoutMargins = NO;
    cell.separatorInset = UIEdgeInsetsZero;
    cell.layoutMargins = UIEdgeInsetsZero;
    // Configure the cell...
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
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
