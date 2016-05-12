//
//  PhotoFullViewController.h
//  Say-QR
//
//  Created by Moin' Victor on 02/11/2015.
//  Copyright © 2015 SayMed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoFullViewController : UIViewController <UIScrollViewDelegate>
@property NSUInteger pageIndex;
@property (strong, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (nonatomic, strong) IBOutlet UIImageView *mainImageView;
@property (nonatomic, strong) UIImage *image;
-(void) imageUpdates;

@end
