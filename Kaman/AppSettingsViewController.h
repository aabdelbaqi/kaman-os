//
//  AppSettingsViewController.h
//  Kaman
//
//  Created by Moin' Victor on 26/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppSettingsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *emailView;
@property (weak, nonatomic) IBOutlet UIView *invitationsView;
@property (weak, nonatomic) IBOutlet UIView *requestsView;
@property (weak, nonatomic) IBOutlet UIView *ratingsView;
@property (weak, nonatomic) IBOutlet UIView *messagesView;
@property (weak, nonatomic) IBOutlet UIView *termsView;
@property (weak, nonatomic) IBOutlet UIView *privacyView;
@property (weak, nonatomic) IBOutlet UIButton *logoutButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteAccountButton;
@property (weak, nonatomic) IBOutlet UIButton *updateEmailButton;

@property (weak, nonatomic) IBOutlet UISwitch *invitationsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *requestsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *ratingsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *messagesSwitch;

@end
