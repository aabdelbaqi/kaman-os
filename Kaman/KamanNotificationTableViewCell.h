//
//  KamanNotificationTableViewCell.h
//  Kaman
//
//  Created by Moin' Victor on 23/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KamanNotificationTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *kamanImageView;
@property (weak, nonatomic) IBOutlet UILabel *kamanNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *editViewButton;
@property (weak, nonatomic) IBOutlet UIButton *button1;
@property (weak, nonatomic) IBOutlet UIButton *button2;
@property (weak, nonatomic) IBOutlet UIButton *button3;
@property (weak, nonatomic) IBOutlet UIView *fakeviewb1;
@property (weak, nonatomic) IBOutlet UIStackView *stackviewb1;

@property (weak,nonatomic) IBOutlet NSLayoutConstraint *imageViewWidthConstraint;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *imageViewHeightConstraint;
@end
