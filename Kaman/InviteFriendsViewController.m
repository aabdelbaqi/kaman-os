//
//  InviteFriendsViewController.m
//  Kaman
//
//  Created by Moin' Victor on 15/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import "InviteFriendsViewController.h"
#import "Utils.h"
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "InviteKamansViewController.h"
#import "HostKamanViewController.h"

@interface InviteFriendsViewController ()

@end

@implementation InviteFriendsViewController
NSString * shareMessage;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBarTintColor:
     [UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:MyOrangeColor}];
    [self.navigationController.navigationItem.leftBarButtonItem setTintColor:MyOrangeColor];
    self.view.backgroundColor = MyBrownColor;

    [self prepareButton:self.fbShare WithColor:FacebookBlueColor andImage:[UIImage imageNamed:@"facebook"]];
    [self prepareButton:self.whatsappShare WithColor:WhatsappGreenColor andImage:[UIImage imageNamed:@"whatsapp"]];
    
    [self.kamanNameSeperator setBackgroundColor:MyGreyColor];
    [self setTitle:@"Invite Friends"];
    
    UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
    imageView1.center = CGPointMake(10, self.editButton.frame.size.height / 2);
    imageView1.image = [UIImage imageNamed:@"edit-small"];
    [self.editButton addSubview:imageView1];
    [self.editButton addTarget:self action:@selector(editKaman:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.kaman != nil) {
        self.kamanName.text = [self.kaman objectForKey:@"Name"];
        [self prepareButton:self.kamanShare WithColor:MyOrangeColor andImage:[UIImage imageNamed:@"kaman-icon"]];
    } else {
          [self.kamanShare setTitle:@"Invite Via Email" forState:UIControlStateNormal];
        [self.kamanName setAlpha:0.0];
        [self.editButton setAlpha:0.0];
        [self.kamanNameSeperator setAlpha:0.0];
        [self.shareLabel setText:@"Know any Kamaners like you? Get the word out!"];
        [self prepareButton:self.kamanShare WithColor:MailBlueColor andImage:[UIImage imageNamed:@"email-filled"]];
    }
    
    if (self.kaman != nil) {
        shareMessage = [NSString stringWithFormat:@"You are invited to my party. Download Kaman for details. Kaman shows you private parties and events nearby. '%@",APP_STORE_LINK];
    } else {
        shareMessage = [NSString stringWithFormat:@"Check out Kaman. Shows you private parties and events nearby. '%@'",APP_STORE_LINK];
    }

}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) prepareButton: (UIButton*) button WithColor: (UIColor*) color andImage: (UIImage*) image
{
    [[button layer] setBorderWidth:2.0f];
    [[button layer] setBorderColor:color.CGColor];
    button.layer.cornerRadius = 10;
    button.clipsToBounds = YES;
    //[button setImage:image forState:UIControlStateNormal];
    
    UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    imageView1.center = CGPointMake(25, button.frame.size.height / 2);
    imageView1.image = image;
    [button addSubview:imageView1];
    [button setTitleColor:MyDarkGrayColor forState:UIControlStateNormal];
}

-(IBAction)shareFacebook:(id)sender
{
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:APP_STORE_LINK];
    content.contentDescription = shareMessage;
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb-messenger://"]]) {
        [FBSDKMessageDialog showWithContent:content delegate:nil];
    } else {
        [FBSDKShareDialog showFromViewController:self
                                     withContent:content
                                        delegate:nil];
    }
}



- (IBAction)exit:(id)sender {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(IBAction)shareWhatsApp:(id)sender
{
    
    NSString * msg = shareMessage;
    
    msg = [msg stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
    msg = [msg stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
    msg = [msg stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
    msg = [msg stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
    msg = [msg stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
    msg = [msg stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    msg = [msg stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    NSURL *whatsappURL = [NSURL URLWithString:[NSString stringWithFormat:@"whatsapp://send?text=%@",msg]];
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
    } else {
        [Utils showMessageHUDInView:self.view withMessage:@"Whatsapp not installed" afterError:YES];
    }
}



-(void) editKaman:(id) sender
{

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
    
    HostKamanViewController *someViewController = [storyboard instantiateViewControllerWithIdentifier:@"host_kaman"];
    someViewController.kaman = self.kaman;
    [self.navigationController pushViewController:someViewController animated:YES];
    
}


-(IBAction) inviteKamans: (id) sender
{
    
    if(self.kaman == nil) {
        // From within your active view controller
        if([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
            mailCont.mailComposeDelegate = self;
            
            [mailCont setSubject:@"Join Kaman and Lets Party"];
           // [mailCont setToRecipients:[NSArray arrayWithObject:@"joel@stackoverflow.com"]];
            [mailCont setMessageBody:shareMessage isHTML:NO];
            
            [self presentModalViewController:mailCont animated:YES];
        }
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        
        InviteKamansViewController *someViewController = [storyboard instantiateViewControllerWithIdentifier:@"invite_kamans"];
        someViewController.kaman = self.kaman;
        someViewController.showButtons = YES;
        [self.navigationController pushViewController:someViewController animated:YES];
    }
}

// Then implement the delegate method
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissModalViewControllerAnimated:YES];
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
