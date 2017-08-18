//
//  InviteFriendsViewController.h
//  Kaman
//
//  Created by Moin' Victor on 15/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utils.h"

#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface InviteFriendsViewController : UIViewController <MFMailComposeViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *fbShare;
@property (weak, nonatomic) IBOutlet UIButton *kamanShare;
@property (weak, nonatomic) IBOutlet UIButton *whatsappShare;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

@property (weak, nonatomic) IBOutlet UILabel *kamanName;
@property (weak, nonatomic) IBOutlet UILabel *shareLabel;
@property (weak, nonatomic) IBOutlet UIView *kamanNameSeperator;
@property  PFObject *kaman;

@end
