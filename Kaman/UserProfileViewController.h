//
//  UserProfileViewController.h
//  Kaman
//
//  Created by Moin' Victor on 04/12/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utils.h"

@interface UserProfileViewController : UITableViewController
@property NSMutableArray *users;

@property BOOL showButtons, headerPannable;
-(void)acceptClicked;
-(void)declineClicked;
@property PFObject *kamanObject;

@end
