//
//  DiscoveryViewController.m
//  Kaman
//
//  Created by Moin' Victor on 26/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import "DiscoveryViewController.h"
#import "Utils.h"
#import "RangeSlider.h"

@interface DiscoveryViewController ()

@end

@implementation DiscoveryViewController


- (IBAction)exit:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Discovery Settings"];
    
    [self.navigationController.navigationBar setBarTintColor:
     [UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:MyOrangeColor}];
    [self.navigationController.navigationItem.leftBarButtonItem setTintColor:MyOrangeColor];
    self.view.backgroundColor = MyBrownColor;
    
    [Utils setUIView:self.visibilityView backgroundColor:[UIColor whiteColor] andRoundedByRadius:10 withBorderColor:MyGreyColor];
    [Utils setUIView:self.discoverFriendsView backgroundColor:[UIColor whiteColor] andRoundedByRadius:10 withBorderColor:MyGreyColor];
    [Utils setUIView:self.distanceView backgroundColor:[UIColor whiteColor] andRoundedByRadius:10 withBorderColor:MyGreyColor];
    [Utils setUIView:self.ageView backgroundColor:[UIColor whiteColor] andRoundedByRadius:10 withBorderColor:MyGreyColor];
    
    self.ageSlider = [[RangeSlider alloc] initWithFrame:CGRectMake(6, 10, self.view.frame.size.width - 40, 30)];
    //[[RangeSlider alloc] initWithFrame:self.distanceSlider.frame]; // the slider enforces a height of 30, although I'm not sure that this is necessary
    //[self.ageSlider setMinimumRangeLength:(DEFAULT_KAMAN_USER_MINIMUM_AGE/DEFAULT_KAMAN_USER_MAXIMUM_AGE)];
      // slider.minimumRangeLength = .03; // this property enforces a minimum range size. By default it is set to 0.0
    
    [self.ageSlider setMinThumbImage:[UIImage imageNamed:@"rangethumb.png"]]; // the two thumb controls are given custom images
    [self.ageSlider setMaxThumbImage:[UIImage imageNamed:@"rangethumb.png"]];
    
    
    UIImage *image; // there are two track images, one for the range "track", and one for the filled in region of the track between the slider thumbs
    
    [self.ageSlider setTrackImage:[[UIImage imageNamed:@"fullrange.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(9.0, 9.0, 9.0, 9.0)]];
    
    image = [UIImage imageNamed:@"fillrange.png"];
    [self.ageSlider setInRangeTrackImage:image];
    
    [self.ageView addSubview:self.ageSlider];
    NSMutableArray * constraints = [NSMutableArray array];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.ageView
                                                        attribute:NSLayoutAttributeLeftMargin
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.ageSlider
                                                        attribute:NSLayoutAttributeLeft
                                                       multiplier:1.0
                                                         constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.ageView
                                                        attribute:NSLayoutAttributeRightMargin 
                                                        relatedBy:NSLayoutRelationEqual 
                                                           toItem:self.ageSlider
                                                        attribute:NSLayoutAttributeRight
                                                       multiplier:1.0
                                                         constant:0]];
   // [self.ageView addConstraints:constraints];
    
    [self.ageSlider addTarget:self action:@selector(ageSlider:withEvent:) forControlEvents:UIControlEventValueChanged]; // The slider sends actions when the value of the minimum or maximum changes
    
    
    [self.distanceSlider addTarget:self action:@selector(distanceSlider:withEvent:) forControlEvents:UIControlEventValueChanged]; // The slider sends actions when the value of the minimum or maximum changes
     [self updateUI];
}


- (IBAction)ageSlider:(RangeSlider *)itemSlider withEvent:(UIEvent*)e;
{
    UITouch * touch = [e.allTouches anyObject];
    int maxAge = self.ageSlider.max * DEFAULT_KAMAN_USER_MAXIMUM_AGE;
    int minAge = self.ageSlider.min * DEFAULT_KAMAN_USER_MAXIMUM_AGE;
    
    [self.ageLabel setText:[NSString stringWithFormat:@"%d - %d",minAge,maxAge]];
    
    if( touch.phase != UITouchPhaseMoved && touch.phase != UITouchPhaseBegan)
    {
        //The user hasn't ended using the slider yet.
    } else {
        [[PFUser currentUser] updateUserColumn:@"DiscoveryAgeMin" withValue:[NSNumber numberWithInt:minAge] onCallBack:^(id result) {
            
        }];
        [[PFUser currentUser] updateUserColumn:@"DiscoveryAgeMax" withValue:[NSNumber numberWithInt:maxAge] onCallBack:^(id result) {
            
        }];
    }
    
}



- (IBAction)distanceSlider:(UISlider *)itemSlider withEvent:(UIEvent*)e;
{
    UITouch * touch = [e.allTouches anyObject];
    int distance = self.distanceSlider.value;
    
    [self.distanceLabel setText:[NSString stringWithFormat:@"%d KMs",distance]];
    
    if( touch.phase != UITouchPhaseMoved && touch.phase != UITouchPhaseBegan)
    {
        //The user hasn't ended using the slider yet.
    } else {
        [[PFUser currentUser] updateUserColumn:@"DiscoveryPerimeter" withValue:[NSNumber numberWithInt:distance] onCallBack:^(id result) {
            
        }];
    }
    
}


-(void) updateUI
{
    PFUser * user = [PFUser currentUser];
    /*NSString *email = [user objectForKey:@"email"];
    if([email isEqual:[NSNull null]]) {
        [self.updateEmailButton setTitle:@"Tap To Set" forState:UIControlStateNormal];
        [self.updateEmailButton setTitleColor:MyDarkGrayColor forState:UIControlStateNormal];
    } else {
        [self.updateEmailButton setTitle:email forState:UIControlStateNormal];
        [self.updateEmailButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }
    */
    
    [self.distanceSlider setValue:[user discoveryPerimeter].intValue];
    [self.distanceLabel setText:[NSString stringWithFormat:@"%d KMs",[user discoveryPerimeter].intValue]];
    
    NSNumber *ageMinNSNumber = [user discoveryAgeMin];
    NSNumber *ageMaxNSNumber = [user discoveryAgeMax];
   
    [self.ageLabel setText:[NSString stringWithFormat:@"%d - %d",ageMinNSNumber.intValue,ageMaxNSNumber.intValue]];
    [self.ageSlider setMin:(ageMinNSNumber.intValue/DEFAULT_KAMAN_USER_MAXIMUM_AGE)];
    [self.ageSlider setMax:(ageMaxNSNumber.intValue/DEFAULT_KAMAN_USER_MAXIMUM_AGE)];
    [self.ageSlider setNeedsDisplay];
    [self.discoverFriendsSwitch setOn:[user discoveredByFriendsOnly] animated:YES];
    
    [self.visibilitySwitch setOn:[user isVisibileToOtherKamans] animated:YES];
   
    
}

-(IBAction)switchedValueChanged:(id)sender
{
    
    if(self.discoverFriendsSwitch == sender) {
        [[PFUser currentUser] updateUserColumn:@"DiscoverFriendsOnly" withValue:[NSNumber numberWithBool: [self.discoverFriendsSwitch isOn]] onCallBack:^(id result) {
            [self updateUI];
        }];
    }
    
    if(self.visibilitySwitch == sender) {
        [[PFUser currentUser] updateUserColumn:@"Visibility" withValue:[NSNumber numberWithBool: [self.visibilitySwitch isOn]] onCallBack:^(id result) {
            [self updateUI];
        }];
    }
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
