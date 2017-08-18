//
//  ViewController.h
//  Kaman
//
//  Created by Moin' Victor on 11/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface LoginViewController : UIViewController  <FBSDKLoginButtonDelegate>

@property (weak, nonatomic) IBOutlet FBSDKLoginButton *fbLoginBtn;
@property (weak, nonatomic) IBOutlet UIView *agreeView;
@end

