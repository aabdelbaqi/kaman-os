//
// Created by guti on 1/17/14.
//
// No bugs for you!
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GGOverlayView.h"

typedef void(^DismissCallback)(GGOverlayViewMode mode);

@class GGOverlayView;


@interface GGDraggableView : UIView

-(void) initDragEventsOnView:(UIView*) view onDismissCallBack:(DismissCallback)onDismiss;

@end
