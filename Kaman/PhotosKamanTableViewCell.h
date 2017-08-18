//
//  PhotosKamanTableViewCell.h
//  Kaman
//
//  Created by Moin' Victor on 17/11/2015.
//  Copyright © 2015 Riad & Co. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GGDraggableView.h"
@interface PhotosKamanTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet GGDraggableView *nextKamanView;
@property (weak, nonatomic) IBOutlet UIImageView *nextKamanImageView;
@property (weak, nonatomic) IBOutlet UILabel *nextKamanNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextFarRightLabel;
@property (weak, nonatomic) IBOutlet UIImageView *nextKamanHostImageView;


@property (weak, nonatomic) IBOutlet GGDraggableView *kamanView;
@property (weak, nonatomic) IBOutlet UIImageView *kamanImageView;
@property (weak, nonatomic) IBOutlet UILabel *kamanNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *farRightLabel;
@property (weak, nonatomic) IBOutlet UIImageView *kamanHostImageView;

@property (weak,nonatomic) IBOutlet NSLayoutConstraint *namePaddingConstraint;
@end
