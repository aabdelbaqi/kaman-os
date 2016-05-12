//
//  AttendeeCollectionViewCell.h
//  Kaman
//
//  Created by Moin' Victor on 01/12/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AttendeeCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *profileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *friendShipLabel;
@end
