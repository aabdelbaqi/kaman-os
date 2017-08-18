//
//  KamansTableEmptyView.h
//  Kaman
//
//  Created by Moin' Victor on 16/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FLAnimatedImage/FLAnimatedImage.h>

@interface KamansTableEmptyView : UIView

@property (weak, nonatomic) IBOutlet UIButton *hostButton;
@property (weak, nonatomic) IBOutlet UIButton *inviteButton;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet FLAnimatedImageView *animImageView;

@end
