//
//  RateUserTableViewCell.h
//  Kaman
//
//  Created by Moin' Victor on 04/12/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RateUserTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIButton *rate0Btn;
@property (weak, nonatomic) IBOutlet UIButton *rate1Btn;
@end
