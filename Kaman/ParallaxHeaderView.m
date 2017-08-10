//
//  ParallaxHeaderView.m
//  ParallaxTableViewHeader
//
//  Created by Vinodh  on 26/10/14.
//  Copyright (c) 2014 Daston~Rhadnojnainva. All rights reserved.

//

#import <QuartzCore/QuartzCore.h>

#import "ParallaxHeaderView.h"
#import "UIImage+ImageEffects.h"

@interface ParallaxHeaderView ()
@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *subView;
@property (nonatomic) IBOutlet UIImageView *bluredImageView;
@property(nonatomic) IBOutlet UIView *blackOverlay;
@end

#define kDefaultHeaderFrame CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)

static CGFloat kParallaxDeltaFactor = 0.1f;
static CGFloat kMaxTitleAlphaOffset = 100.0f;
static CGFloat kLabelPaddingDist = 8.0f;
static CGFloat kBackgroudOpacity = 0.3f;
@implementation ParallaxHeaderView

+ (id)parallaxHeaderViewWithImage:(UIImage *)image forSize:(CGSize)headerSize;
{
    ParallaxHeaderView *headerView = [[ParallaxHeaderView alloc] initWithFrame:CGRectMake(0, 0, headerSize.width, headerSize.height)];
    headerView.headerImage = image;
    [headerView initialSetupForDefaultHeader];
    return headerView;
    
}

+ (id)parallaxHeaderViewWithSubView:(UIView *)subView
{
    ParallaxHeaderView *headerView = [[ParallaxHeaderView alloc] initWithFrame:CGRectMake(0, 0, subView.frame.size.width, subView.frame.size.height)];
    [headerView initialSetupForCustomSubView:subView];
    return headerView;
}

- (void)awakeFromNib
{
    if (self.subView)
        [self initialSetupForCustomSubView:self.subView];
    else
        [self initialSetupForDefaultHeader];
    
    [self refreshBlurViewForNewImage];
}


- (void)layoutHeaderViewForScrollViewOffset:(CGPoint)offset
{
    CGRect frame = self.imageScrollView.frame;
   
    if (offset.y > 0)
    {
        frame.origin.y = MAX(offset.y *kParallaxDeltaFactor, 0);
        self.imageScrollView.frame = frame;
        self.bluredImageView.alpha = 1 * offset.y * 2;
        self.clipsToBounds = YES;
       
    }
    else
    {
        CGFloat delta = 0.0f;
        CGRect rect = kDefaultHeaderFrame;
        delta = fabs(MIN(0.0f, offset.y));
        rect.origin.y -= delta;
        rect.size.height += delta;
        self.bluredImageView.alpha = ((offset.y / kDefaultHeaderFrame.size.height) * 10 + 1.5 + fabs(kDefaultHeaderFrame.size.height / 100));
        if (kDefaultHeaderFrame.size.height >= 300) {
            self.bluredImageView.alpha -= 2.0;
        }
        
        self.imageScrollView.frame = rect;
        self.clipsToBounds = NO;
        // NSLog(@"Alpha up %f from offset %f & height %f",self.bluredImageView.alpha, offset.y,kDefaultHeaderFrame.size.height);
        self.headerTitleLabel.alpha = 1 - (delta) * 1 / kMaxTitleAlphaOffset;
        for (UIView *sv in self.subviews) {
            if(sv.tag == 1000)
                sv.alpha = (1 - (delta) * 1 / kMaxTitleAlphaOffset)+0.65;
        }
    }
}

- (void)refreshBlurViewForNewImage
{
    UIImage *screenShot = _headerImage;//[self screenShotOfView:self];
    screenShot = [screenShot applyDarkEffect];
    //[screenShot applyBlurWithRadius:6 tintColor:[UIColor colorWithWhite:0.6 alpha:0.5] saturationDeltaFactor:1.0 maskImage:nil];
    self.bluredImageView.image = screenShot;
    [self.imageScrollView bringSubviewToFront:self.bluredImageView];

}

#pragma mark -
#pragma mark Private

- (void)initialSetupForDefaultHeader
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.imageScrollView = scrollView;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:scrollView.bounds];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.image = self.headerImage;
    self.imageView = imageView;
    [self.imageScrollView addSubview:self.imageView];
    
    CGRect labelRect = self.imageScrollView.bounds;
    labelRect.origin.x = labelRect.origin.y = kLabelPaddingDist;
    labelRect.size.width = labelRect.size.width - 2 * kLabelPaddingDist;
    labelRect.size.height = labelRect.size.height - 2 * kLabelPaddingDist;
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:labelRect];
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.numberOfLines = 0;
    headerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    headerLabel.autoresizingMask = imageView.autoresizingMask;
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.font = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:23];
    self.headerTitleLabel = headerLabel;
    [self.imageScrollView addSubview:self.headerTitleLabel];
    
    self.bluredImageView = [[UIImageView alloc] initWithFrame:self.imageView.frame];
    self.bluredImageView.autoresizingMask = self.imageView.autoresizingMask;
    self.bluredImageView.alpha = 0.2222f;
    [self.imageScrollView addSubview:self.bluredImageView];
   
    self.blackOverlay = [[UIView alloc] initWithFrame:self.imageView.frame];
    self.blackOverlay.layer.backgroundColor = [[UIColor blackColor] CGColor];
    self.blackOverlay.layer.opacity = 0.3f;
    self.blackOverlay.tag = 1000;
    self.blackOverlay.alpha = 0.0f;
    self.blackOverlay.autoresizingMask = self.imageView.autoresizingMask;
    //[self.imageScrollView addSubview: self.blackOverlay];
    
    [self addSubview:self.imageScrollView];
    
    [self refreshBlurViewForNewImage];
}

- (void)initialSetupForCustomSubView:(UIView *)subView
{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.imageScrollView = scrollView;
    self.subView = subView;
    subView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.imageScrollView addSubview:subView];
    
    self.bluredImageView = [[UIImageView alloc] initWithFrame:subView.frame];
    self.bluredImageView.autoresizingMask = subView.autoresizingMask;
    self.bluredImageView.alpha = 0.0f;
    [self.imageScrollView addSubview:self.bluredImageView];
    
    [self addSubview:self.imageScrollView];
    [self refreshBlurViewForNewImage];
}

- (void)setHeaderImage:(UIImage *)headerImage
{
    _headerImage = headerImage;
    self.imageView.image = headerImage;
    [self refreshBlurViewForNewImage];
}

- (UIImage *)screenShotOfView:(UIView *)view
{
    UIGraphicsBeginImageContextWithOptions(kDefaultHeaderFrame.size, YES, 0.0);
    [self drawViewHierarchyInRect:kDefaultHeaderFrame afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
