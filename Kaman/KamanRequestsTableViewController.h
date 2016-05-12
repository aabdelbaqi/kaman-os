//
//  KamanRequestsTableViewController.h
//  Kaman
//
//  Created by Moin' Victor on 30/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utils.h"

@interface KamanRequestsTableViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property NSMutableArray *kamanRequests;
@property PFObject *kaman;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
