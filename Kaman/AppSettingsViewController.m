//
//  AppSettingsViewController.m
//  Kaman
//
//  Created by Moin' Victor on 26/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import "AppSettingsViewController.h"
#import "Utils.h"
#import <FBSDKLoginKit/FBSDKLoginKit.h>


@interface AppSettingsViewController ()

@end

@implementation AppSettingsViewController



- (IBAction)exit:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)logout:(id)sender
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Logout"
                                  message:@"Really logout"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Yes"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             
                             FBSDKLoginManager *loginManager = [[FBSDKLoginManager alloc] init];
                             [loginManager logOut];
                             [self exit:nil];
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
   
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"App Settings"];

    [self.navigationController.navigationBar setBarTintColor:
     [UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:MyOrangeColor}];
    [self.navigationController.navigationItem.leftBarButtonItem setTintColor:MyOrangeColor];
    self.view.backgroundColor = MyBrownColor;
    
    [Utils styleButton:self.logoutButton bgColor:MyOrangeColor highlightColor:MyGreyColor];
    [Utils styleButton:self.deleteAccountButton bgColor:[UIColor blackColor] highlightColor:MyGreyColor];

    [Utils setUIView:self.emailView backgroundColor:[UIColor whiteColor] andRoundedByRadius:10 withBorderColor:MyGreyColor];
    [Utils setUIView:self.invitationsView backgroundColor:[UIColor whiteColor] andRoundedByRadius:10 withBorderColor:MyGreyColor];
    [Utils setUIView:self.requestsView backgroundColor:[UIColor whiteColor] andRoundedByRadius:10 withBorderColor:MyGreyColor];
    [Utils setUIView:self.ratingsView backgroundColor:[UIColor whiteColor] andRoundedByRadius:10 withBorderColor:MyGreyColor];
    [Utils setUIView:self.messagesView backgroundColor:[UIColor whiteColor] andRoundedByRadius:10 withBorderColor:MyGreyColor];
    [Utils setUIView:self.termsView backgroundColor:[UIColor whiteColor] andRoundedByRadius:10 withBorderColor:MyGreyColor];
    [Utils setUIView:self.privacyView backgroundColor:[UIColor whiteColor] andRoundedByRadius:10 withBorderColor:MyGreyColor];
    
    SEL termsAction = @selector(tapOnTermsOfServiceLink:);
    
    SEL privacyAction = @selector(tapOnPrivacyPolicyLink:);
    [self.termsView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                       action:termsAction]];
    
    [self.privacyView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                 action:privacyAction]];
    self.updateEmailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    
    [self updateUI];
}

- (void)tapOnTermsOfServiceLink:(UITapGestureRecognizer *)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"User tapped on the Terms of Service link");
        [Utils goToTerms:self skipToPrivacy:NO];
    }
}

- (void)tapOnPrivacyPolicyLink:(UITapGestureRecognizer *)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded)
    {
        NSLog(@"User tapped on the Privacy Policy link");
        [Utils goToTerms:self skipToPrivacy:YES];
    }
}


-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateUI];
}

-(void) updateUI
{
    PFUser * user = [PFUser currentUser];
    if([user.email isEqual:[NSNull null]]) {
        [self.updateEmailButton setTitle:@"Tap To Set" forState:UIControlStateNormal];
        [self.updateEmailButton setTitleColor:MyDarkGrayColor forState:UIControlStateNormal];
    } else {
        [self.updateEmailButton setTitle:user.email forState:UIControlStateNormal];
        [self.updateEmailButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }
    
    [self.requestsSwitch setOn:[user notifyRequests] animated:YES];
    
    [self.invitationsSwitch setOn:[user notifyInvites] animated:YES];
    
    [self.ratingsSwitch setOn:[user notifyRatings] animated:YES];
    
    [self.messagesSwitch setOn:[user notifyMessages] animated:YES];

}

-(IBAction)switchedValueChanged:(id)sender
{
    if(self.requestsSwitch == sender) {
        [[PFUser currentUser] updateUserColumn:@"NotifyRequests" withValue:[NSNumber numberWithBool: [self.requestsSwitch isOn]] onCallBack:^(id result) {
            [self updateUI];
        }];
    }
    if(self.invitationsSwitch == sender) {
        [[PFUser currentUser] updateUserColumn:@"NotifyInvites" withValue:[NSNumber numberWithBool: [self.invitationsSwitch isOn]] onCallBack:^(id result) {
            [self updateUI];
        }];
    }
    
    if(self.ratingsSwitch == sender) {
        [[PFUser currentUser] updateUserColumn:@"NotifyRatings" withValue:[NSNumber numberWithBool: [self.ratingsSwitch isOn]] onCallBack:^(id result) {
            [self updateUI];
        }];
    }
    
    if(self.messagesSwitch == sender) {
        [[PFUser currentUser] updateUserColumn:@"NotifyMessages" withValue:[NSNumber numberWithBool: [self.messagesSwitch isOn]] onCallBack:^(id result) {
            [self updateUI];
        }];
    }
}


-(IBAction)promptDeleteAccount:(id)sender
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Delete Your Account"
                                  message:@"Pressing OK will delete all your account information from our backend and consequently logout your current session. Please press OK if you wish to proceed, otherwise press Cancel."
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             
                             [self deleteUser];
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
 
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

-(void) deleteUser
{
    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" equalTo:[PFUser currentUser].objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [PFUser deleteAll:objects];
            [self logout:nil];
#warning TODO delete invites, requests e.t.c
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(IBAction)promptUpdateEmail:(id)sender
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Update Your Email Address"
                                  message:@"Enter your email address below"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             UITextField *temp = alert.textFields.firstObject;
                             
                             // Get the text from your textField
                             NSString *email = temp.text;
                             if(![email isValidEmail]) {
                                 [Utils showMessageHUDInView:self.view withMessage:@"Invalid email address format" afterError:YES];
                                 [temp becomeFirstResponder];
                                 return;
                             } else {
                                 [self.updateEmailButton setTitle:email forState:UIControlStateNormal];
                                 [self.updateEmailButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
                                 [[PFUser currentUser] updateUserColumn:@"email" withValue:email onCallBack:^(id result) {
                                     [self updateUI];
                                 }];
                             }
                             [alert dismissViewControllerAnimated:YES completion:nil];
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"email@example.com"; //hint
        [textField setKeyboardType:UIKeyboardTypeEmailAddress];
    }];
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
