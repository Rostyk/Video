//
//  MTInfoView.m
//  Video
//
//  Created by Rostyslav Stepanyak on 6/18/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import "MTInfoView.h"

#define VIEW_DEVIATION                      40

@interface MTInfoView()
@property (nonatomic, weak)IBOutlet UIView *dimView;
@property (nonatomic) CGRect originFrame;
@end

@implementation MTInfoView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    _originFrame = CGRectZero;
    return self;
}

- (void)setAnimationValue:(CGFloat)animationValue {
    _animationValue = animationValue;
    
    // save original frame
    if (CGRectEqualToRect(self.originFrame, CGRectZero)) {
        self.originFrame = self.frame;
    }
    
    //Fading in
    self.alpha = animationValue;
    
    //slightly shift the view
    CGRect shiftedFrame = self.originFrame;
    
    if (self.moveDirection == SwipeLeft)
        shiftedFrame.origin.x += (VIEW_DEVIATION - (VIEW_DEVIATION * animationValue));
    
    if (self.moveDirection == SwipeRight)
        shiftedFrame.origin.x -= (VIEW_DEVIATION - (VIEW_DEVIATION * animationValue));
    
    self.frame = shiftedFrame;
    
    //dim off
    self.dimView.alpha = 1 - animationValue;
}

@end
