//
//  PickChatUserTableViewController.h
//  Kaman
//
//  Created by Moin' Victor on 02/12/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utils.h"

@class PickChatUserTableViewController;

@protocol PickChatUserTableViewControllerDelegate <NSObject>

- (void)didSelectAttendee:(PFUser *)user withAvatar: (UIImage*) image forKaman:(PFObject*) kaman ;

@end

@interface PickChatUserTableViewController : UITableViewController
@property PFObject * kaman;
@property (weak, nonatomic) id<PickChatUserTableViewControllerDelegate> pickChatUserDelegate;
@end
