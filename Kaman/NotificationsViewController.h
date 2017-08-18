//
//  NotificationsViewController.h
//  Kaman
//
//  Created by Moin' Victor on 23/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickChatUserTableViewController.h"

@interface NotificationsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate, PickChatUserTableViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *fakeView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *announceBarButton;

-(void) updateNotifBadgesThenReload:(BOOL)reload;

@end
