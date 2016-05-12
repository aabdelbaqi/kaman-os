//
//  DiscoveryViewController.h
//  Kaman
//
//  Created by Moin' Victor on 26/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RangeSlider.h"

@interface DiscoveryViewController : UIViewController


@property (weak, nonatomic) IBOutlet UIView *visibilityView;
@property (weak, nonatomic) IBOutlet UIView *discoverFriendsView;
@property (weak, nonatomic) IBOutlet UIView *distanceView;
@property (weak, nonatomic) IBOutlet UIView *ageView;

@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;

@property (weak, nonatomic) IBOutlet UISwitch *visibilitySwitch;
@property (weak, nonatomic) IBOutlet UISwitch *discoverFriendsSwitch;

@property (weak, nonatomic) IBOutlet UISlider *distanceSlider;
@property (strong, nonatomic) RangeSlider *ageSlider;


@end
