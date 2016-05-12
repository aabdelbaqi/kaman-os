#import "GGOverlayView.h"

@interface GGOverlayView ()
@property (nonatomic, strong) UIImageView *imageView;
@end
CGFloat x, y;
@implementation GGOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;

    self.backgroundColor = [UIColor whiteColor];
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"trollface-"]];
    x = 150;
    y = 150;
    [self addSubview:self.imageView];
    
    return self;
}

- (void)setMode:(GGOverlayViewMode)mode
{
    if (_mode == mode) return;

    _mode = mode;
    if (mode == GGOverlayViewModeLeft) {
        self.imageView.image = [UIImage imageNamed:@"trollface-"];
    } else {
        self.imageView.image = [UIImage imageNamed:@"thumbs-up"];
    }
}

-(void)centerImageto: (CGPoint) center
{
    self.imageView.center = center;
    x = center.x;
    y = center.y;

}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(x, y, 100, 100);
}

@end