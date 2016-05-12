//
//  DetailKamanTableViewCell.h
//  Kaman
//
//  Created by Moin' Victor on 19/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailKamanTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *detailTagLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailValueLabel;
@property (weak, nonatomic) IBOutlet UIView *seperatorView;
@property (weak, nonatomic) IBOutlet UIButton *rateLow;
@property (weak, nonatomic) IBOutlet UIButton *rateHigh;
@end
