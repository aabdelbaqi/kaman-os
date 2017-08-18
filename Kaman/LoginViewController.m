//
//  ViewController.m
//  Kaman
//
//  Created by Moin' Victor on 11/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import "LoginViewController.h"
#import <JGProgressHUD/JGProgressHUD.h>
#import "SWRevealViewController.h"
#import "Utils.h"
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>


@interface LoginViewController ()

@end


@implementation LoginViewController


- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
    [[PFUser currentUser] fetchInBackground];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self buildAgreeTextViewFromString:@"#<ts>Terms Of Use# and #<pp>Commercial Use #"];
    
    self.fbLoginBtn.delegate = self;
    self.fbLoginBtn.readPermissions =
    @[@"public_profile", @"email", @"user_birthday",@"user_friends"];
    
    // check if Facebook session exists
    if ([FBSDKAccessToken currentAccessToken]) { // user session already exists
        [self processFBLoginWithAccessToken:[FBSDKAccessToken currentAccessToken]];
    } else {
        NSLog(@"Facebook session does not exist");
        

    }

    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:self.view.bounds];
    
    backgroundImage.image = [UIImage imageNamed:@"login-bg"];
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
}

-(void) goHome
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    SWRevealViewController *someViewController = [storyboard instantiateViewControllerWithIdentifier:@"home"];
    [self presentViewController:someViewController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buildAgreeTextViewFromString:(NSString *)localizedString
{
    // 1. Split the localized string on the # sign:
    NSArray *localizedStringPieces = [localizedString componentsSeparatedByString:@"#"];
    
    // 2. Loop through all the pieces:
    NSUInteger msgChunkCount = localizedStringPieces ? localizedStringPieces.count : 0;
    CGPoint wordLocation = CGPointMake(0.0, 0.0);
    for (NSUInteger i = 0; i < msgChunkCount; i++)
    {
        NSString *chunk = [localizedStringPieces objectAtIndex:i];
        if ([chunk isEqualToString:@""])
        {
            continue;     // skip this loop if the chunk is empty
        }
        
        // 3. Determine what type of word this is:
        BOOL isTermsOfServiceLink = [chunk hasPrefix:@"<ts>"];
        BOOL isPrivacyPolicyLink  = [chunk hasPrefix:@"<pp>"];
        BOOL isLink = (BOOL)(isTermsOfServiceLink || isPrivacyPolicyLink);
        
        // 4. Create label, styling dependent on whether it's a link:
        UILabel *label = [[UILabel alloc] init];
        label.font = [UIFont systemFontOfSize:15.0f];
        label.text = chunk;
        label.userInteractionEnabled = isLink;
        
        if (isLink)
        {
            label.textColor = MyOrangeColor;
            label.highlightedTextColor = MyOrangeColor;
            
            // 5. Set tap gesture for this clickable text:
            SEL selectorAction = isTermsOfServiceLink ? @selector(tapOnTermsOfServiceLink:) : @selector(tapOnPrivacyPolicyLink:);
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                         action:selectorAction];
            [label addGestureRecognizer:tapGesture];
            
            // Trim the markup characters from the label:
            if (isTermsOfServiceLink)
                label.text = [label.text stringByReplacingOccurrencesOfString:@"<ts>" withString:@""];
            if (isPrivacyPolicyLink)
                label.text = [label.text stringByReplacingOccurrencesOfString:@"<pp>" withString:@""];
        }
        else
        {
            label.textColor = [UIColor blackColor];
        }
        
        // 6. Lay out the labels so it forms a complete sentence again:
        
        // If this word doesn't fit at end of this line, then move it to the next
        // line and make sure any leading spaces are stripped off so it aligns nicely:
        
        [label sizeToFit];
        
        if (self.agreeView.frame.size.width < wordLocation.x + label.bounds.size.width)
        {
            wordLocation.x = 0.0;                       // move this word all the way to the left...
            wordLocation.y += label.frame.size.height;  // ...on the next line
            
            // And trim of any leading white space:
            NSRange startingWhiteSpaceRange = [label.text rangeOfString:@"^\\s*"
                                                                options:NSRegularExpressionSearch];
            if (startingWhiteSpaceRange.location == 0)
            {
                label.text = [label.text stringByReplacingCharactersInRange:startingWhiteSpaceRange
                                                                 withString:@""];
                [label sizeToFit];
            }
        }
        
        // Set the location for this label:
        label.frame = CGRectMake(wordLocation.x,
                                 wordLocation.y,
                                 label.frame.size.width,
                                 label.frame.size.height);
        // Show this label:
        [self.agreeView addSubview:label];
        
        // Update the horizontal position for the next word:
        wordLocation.x += label.frame.size.width;
    }
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

# pragma mark - Facebook login

-(void) processFBLoginWithAccessToken: (FBSDKAccessToken * ) token
{
    /*double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds *   NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
       

    });
     */
    
    JGProgressHUD *HUD = [Utils showProgressDialogInView:self.view withMessage:@"Please wait..."];

    [PFFacebookUtils
     logInInBackgroundWithAccessToken:token
                        block:^(PFUser *user, NSError *error) {
                            [HUD dismissAnimated:YES];
                            if (!user) {
                                NSLog(@"Uh oh. There was an error logging in.");
                            } else {
                                NSLog(@"User logged in through Facebook!");
                                [PFUser becomeInBackground:[[PFUser currentUser] sessionToken] block:^(PFUser *user, NSError *error) {
                                    if(user && !error) {
                                        // ... success
                                        [Utils fetchFBForLogedInUser];
                                        [self goHome];
                                    }
                                    else {
                                        //... handle become error
                                    }
                                }];
                                
                            }
                        }];
}

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    // handle FB logout
}

-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    if(error) {
        
    } else {
        if([result token]) { // login happened
            [self processFBLoginWithAccessToken:[result token]];
        }
    }
}

@end
