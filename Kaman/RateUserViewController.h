//
//  RateUserViewController.h
//  Kaman
//
//  Created by Moin' Victor on 04/12/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utils.h"

@interface RateUserViewController : UITableViewController
@property NSMutableArray * users;
@property PFObject *kaman;
@property BOOL ratingHost;
@end
