#import "GGDraggableView.h"
#import "GGOverlayView.h"
#import "Constants.h"

@interface GGDraggableView ()
@property(nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property(nonatomic) CGPoint originalPoint;
@property(nonatomic, strong) GGOverlayView *overlayView;
@property(nonatomic, strong) UIView *containerView;
@property BOOL dragSetUp;
@property (strong, nonatomic) UIDynamicAnimator *animator;

@end

@implementation GGDraggableView

DismissCallback onDismisscallback;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) return nil;

   // [self initDragEvents];

    return self;
}

-(void) initDragEventsOnView:(UIView*) view onDismissCallBack:(DismissCallback)onDismiss
{
    if(self.dragSetUp == YES) {
        if([self gestureRecognizers])
        return;
    }

    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragged:)];
    
    onDismisscallback = onDismiss;
    self.containerView = view;
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:view];

    [self addGestureRecognizer:self.panGestureRecognizer];
    
    self.overlayView = [[GGOverlayView alloc] initWithFrame:self.bounds];
    self.overlayView.alpha = 0;
    //[self.overlayView centerImageto:self.center];
    [self addSubview:self.overlayView];
    self.dragSetUp = YES;
}


- (void)loadImageAndStyle
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bar"]];
    [self addSubview:imageView];
    self.layer.cornerRadius = 8;
    self.layer.shadowOffset = CGSizeMake(7, 7);
    self.layer.shadowRadius = 5;
    self.layer.shadowOpacity = 0.5;
}

- (void)dismissWithFlick:(CGPoint)velocity andOffset:(UIOffset) offset {
    
    UIPushBehavior *push = [[UIPushBehavior alloc] initWithItems:@[self] mode:UIPushBehaviorModeInstantaneous];
    push.pushDirection = CGVectorMake(velocity.x*0.1, velocity.y*0.1);
    [push setTargetOffsetFromCenter:offset forItem:self];
    push.action = ^{
        if ([self viewIsOffscreen]) {
            [self.animator removeAllBehaviors];
            [self resetViewPositionAndTransformations];
           // [weakSelf dismiss:YES];
            // callback
            if(onDismisscallback) {
                onDismisscallback(self.overlayView.mode);
            }
        }
    };
    [self.animator addBehavior:push];
}

- (BOOL)viewIsOffscreen {
    CGRect visibleRect = self.containerView.bounds;
    return ([self.animator itemsInRect:visibleRect].count == 0);
}

- (CGPoint)targetDismissalPoint:(CGPoint)startingCenter velocity:(CGPoint)velocity {
    return CGPointMake(startingCenter.x + velocity.x/3.0 , startingCenter.y + velocity.y/3.0);
}

- (void)dragged:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGFloat xDistance = [gestureRecognizer translationInView:self].x;
    CGFloat yDistance = [gestureRecognizer translationInView:self].y;
    
    CGPoint translation = [gestureRecognizer translationInView:gestureRecognizer.view];
    CGPoint locationInView = [gestureRecognizer locationInView:gestureRecognizer.view];
    CGPoint velocity = [gestureRecognizer velocityInView:gestureRecognizer.view];
    CGFloat vectorDistance = sqrtf(powf(velocity.x, 2)+powf(velocity.y, 2));
    
   // NSLog(@"Y=%f, X=%f",yDistance,xDistance);
    
    if(yDistance > 5.0 || yDistance < -300.0) {
        [self resetViewPositionAndTransformations];
        return;
    }
    
    CGPoint imageCenter = self.center;
    UIOffset offset = UIOffsetMake(locationInView.x-imageCenter.x, locationInView.y-imageCenter.y);
    
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:{
            self.originalPoint = self.center;
            break;
        };
        case UIGestureRecognizerStateChanged:{
            CGFloat rotationStrength = MIN(xDistance / 320, 1);
            CGFloat rotationAngel = (CGFloat) (2*M_PI/16 * rotationStrength);
            CGFloat scaleStrength = 1 - fabsf(rotationStrength) / 4;
            CGFloat scale = MAX(scaleStrength, 0.93);
            CGAffineTransform transform = CGAffineTransformMakeRotation(rotationAngel);
            CGAffineTransform scaleTransform = CGAffineTransformScale(transform, scale, scale);
            self.transform = scaleTransform;
            self.center = CGPointMake(self.originalPoint.x + xDistance, self.originalPoint.y + yDistance);

            if(yDistance > 0) {
                  self.overlayView.alpha = 0.0;
              //  [self resetViewPositionAndTransformations];
            } else {
                [self updateOverlay:xDistance];
            }
            break;
        };
        case UIGestureRecognizerStateEnded: {
            if(yDistance > 0 || self.overlayView.alpha <= 0.45) {
                [self resetViewPositionAndTransformations];
            } else {
                [self dismissWithFlick:velocity andOffset:offset];
            }
            break;
        };
        case UIGestureRecognizerStatePossible:break;
        case UIGestureRecognizerStateCancelled:
            [self resetViewPositionAndTransformations];
            break;
        case UIGestureRecognizerStateFailed:break;
    }
}

- (void)updateOverlay:(CGFloat)distance
{
    if (distance > 0) {
        self.overlayView.mode = GGOverlayViewModeRight;
    } else if (distance <= 0) {
        self.overlayView.mode = GGOverlayViewModeLeft;
    }
    CGFloat overlayStrength = MIN(fabsf(distance) / 100, 0.5);
    self.overlayView.alpha = overlayStrength;
}

- (void)resetViewPositionAndTransformations
{
    [UIView animateWithDuration:0.2
                     animations:^{
        self.center = self.originalPoint;
        self.transform = CGAffineTransformMakeRotation(0);
        self.overlayView.alpha = 0;
    }];
}

- (void)dealloc
{
    self.dragSetUp = NO;
    [self removeGestureRecognizer:self.panGestureRecognizer];
}

@end