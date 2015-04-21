/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: zhangwei
 Date: 2015-4-1
 Descript:
 
 Modified:
 */

/*
 Copyright (c) 2015 smarttoy. All rights reserved.
 
 Author: zhangwei
 Date: 2015-4-1
 Descript: 控制杆
 
 Modified:
 */

#import <CoreMotion/CoreMotion.h>
#import "srcontrolslider.h"

#define SR_SLIDER_MAX_VALUE 100.0
#define SR_SLIDER_MIN_VALUE 0.0
#define SR_SLIDER_INIT_VALUE 50.0
#define SR_SLIDER_TRANSFORM_ANGLE 1.57079633


@implementation SRContorlSlider


- (id) initWithFrame:(CGRect) frame
{
    if (! (self = [super initWithFrame:frame])) return nil;
    [self setup];
    return self;
}

- (void) setup
{
    [self setMaximumTrackTintColor:[UIColor grayColor]];
    [self setMinimumTrackTintColor:[UIColor grayColor]];
    [self setMaximumValue:SR_SLIDER_MAX_VALUE];
    [self setMinimumValue:SR_SLIDER_MIN_VALUE];
    [self setValue:SR_SLIDER_INIT_VALUE];
    [self setTransform:CGAffineTransformMakeRotation(SR_SLIDER_TRANSFORM_ANGLE)];
    [self addTarget:self action:@selector(sliderReset) forControlEvents:UIControlEventTouchUpInside];
    [self addTarget:self action:@selector(sliderReset) forControlEvents:UIControlEventTouchUpOutside];
}

- (void) sliderReset {
    self.value = SR_SLIDER_INIT_VALUE;
}

- (float) getSliderValue {
    return self.value;
}

@end