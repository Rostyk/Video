//
//  MTVideoView.m
//  Video
//
//  Created by Rostyslav Stepanyak on 6/14/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import "MTVideoView.h"
#import "MTVideScrubber.h"

#define STEP_VALUE                        20
#define LIMIT_DISTANCE                    100
#define BEVEL_WIDTH                       20

@interface MTVideoView()
@property (nonatomic) CGFloat startX;
@property (nonatomic) CGFloat currentX;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) BOOL isScrubberInitialized;
@end


@implementation MTVideoView


- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [self setupScrubber:frame];
}

- (void)setupScrubber:(CGRect)frame {
    if (!self.isScrubberInitialized && frame.size.height != 0) {
        self.clipsToBounds = NO;
        self.isScrubberInitialized = true;
        CGRect rect = CGRectMake(25, frame.origin.y + frame.size.height + 6, self.frame.size.width - 25*2, 20);
        MTVideScrubber *scrubber = [[MTVideScrubber alloc] initWithFrame:rect];
        scrubber.tintColor = [UIColor whiteColor];
        [self setScrubber:scrubber];
        self.clipsToBounds = NO;
        scrubber.value = 0.04;
        [self addSubview:scrubber];
    }
    [self layoutSubviews];
}

- (void)handleTouchBegan:(CGFloat)x {
    self.startX = x;
}

- (void)handleTouchChanged:(CGFloat)x {
    self.currentX = x;
    
    CGFloat distance = x - self.startX;
    
    if (distance > 0) {
        if (self.rightSwipeDisabled == NO) {
            [self.delegate isMovingManuallyForDistance:distance
                                             direction:SwipeRight];
            [self shrink:distance direction:SwipeRight];
        }
    }
    else {
        if (self.leftSwipeDisabled == NO) {
            [self.delegate isMovingManuallyForDistance:distance
                                             direction:SwipeLeft];
            [self shrink:fabs(distance) direction:SwipeLeft];
        }
    }

}

- (void)handleTouchEnded:(CGFloat)x {
    NSLog(@"[Pan] ended");
    self.currentX = x;
    CGFloat distance = x - self.startX;

    //NSLog(@"Distnace: %f", distance);
    
    if (distance > 0) {
        if (self.rightSwipeDisabled == NO)
            [self resolveAnimation:SwipeRight];
        else
            [self clearMask];
    }
    else {
        if (self.leftSwipeDisabled == NO)
            [self resolveAnimation:SwipeLeft];
        else
            [self clearMask];
    }
}


#pragma mark - event response
- (void)didRecognizedLeftSwipeRecognizer:(UISwipeGestureRecognizer *)swipeRecognizer
{
    NSLog(@"Swiped left");
}

- (void)didRecognizedRightSwipeRecognizer:(UISwipeGestureRecognizer *)swipeRecognizer
{
    NSLog(@"Swiped right");
}

- (void)resolveAnimation:(SwipeDirection)direction {
    CGFloat distance = self.currentX - self.startX;
    
    if (fabs(distance) > LIMIT_DISTANCE) {
        if (direction == SwipeRight) {
            [self.timer invalidate];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                          target:self
                                                        selector:@selector(animateRight)
                                                        userInfo:nil
                                                         repeats:YES];
        }
        
        if (direction == SwipeLeft) {
            [self.timer invalidate];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                          target:self
                                                        selector:@selector(animateLeft)
                                                        userInfo:nil
                                                         repeats:YES];
        }
    }
    else {
        if(direction == SwipeRight) {
            [self.delegate videoReleasedWithNoSwipeWhileAnimatedTo:SwipeRight];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                          target:self
                                                        selector:@selector(restoreByExpandingToLeft)
                                                        userInfo:nil
                                                         repeats:YES];
        }
        if(direction == SwipeLeft) {
            [self.delegate videoReleasedWithNoSwipeWhileAnimatedTo:SwipeLeft];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                          target:self
                                                        selector:@selector(restoreByExpandingToRight)
                                                        userInfo:nil
                                                         repeats:YES];
        }
    }
}

- (void)restoreByExpandingToLeft {
    self.currentX -= STEP_VALUE/2;
    CGFloat distance =  self.currentX -self.startX;
    if (self.currentX < self.startX) {
        [self.timer invalidate];
        self.timer = nil;
        
        [self clearMask];
        [self.delegate isAnimatingForDistance:0 direction:SwipeLeft];
    }
    else {
        [self.delegate isAnimatingForDistance:distance direction:SwipeLeft];
        [self shrink:distance direction:SwipeRight];
    }
}

- (void)restoreByExpandingToRight {
    self.currentX += STEP_VALUE/2;
    if (self.currentX > self.startX) {
        [self.timer invalidate];
        self.timer = nil;
        
        [self clearMask];
        [self.delegate isAnimatingForDistance:0 direction:SwipeRight];
    }
    else {
        CGFloat distance =  self.currentX - self.startX;
        [self.delegate isAnimatingForDistance:distance direction:SwipeRight];
        [self shrink:distance direction:SwipeLeft];
    }
}

- (void)animateRight {
    self.currentX += STEP_VALUE;
    CGFloat distance = fabs(self.startX - self.currentX);
    
    if (distance > self.frame.size.width) {
        [self.timer invalidate];
        self.timer = nil;
        
        [self pause];
        [self clearMask];
        [self.delegate isAnimatingForDistance:self.frame.size.width direction:SwipeRight];
        [self.delegate videoSwiped:SwipeRight];
    }
    else {
        [self.delegate isAnimatingForDistance:distance direction:SwipeRight];
        [self shrink:distance direction:SwipeRight];
    }
}

- (void)animateLeft {
    self.currentX -= STEP_VALUE;
    CGFloat distance = fabs(self.startX - self.currentX);
    
    if (distance > self.frame.size.width) {
        [self.timer invalidate];
        self.timer = nil;
        
        [self pause];
        [self clearMask];
        [self.delegate isAnimatingForDistance:self.frame.size.width direction:SwipeLeft];
        [self.delegate videoSwiped:SwipeLeft];
    }
    else {
        [self.delegate isAnimatingForDistance:distance direction:SwipeLeft];
        [self shrink:distance direction:SwipeLeft];
    }
}

- (void)shrink:(CGFloat)distance direction:(SwipeDirection)direction {
    UIBezierPath *path = [self rectPath:distance direction:direction];
    
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = path.CGPath;
    
    self.layer.mask = mask;
    self.clipsToBounds = NO;
}

- (void)clearMask {
    self.layer.mask = nil;
}

- (UIBezierPath *)rectPath:(CGFloat)distance direction:(SwipeDirection)direction{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGFloat bevel = MIN(distance, BEVEL_WIDTH);
    
    if (direction == SwipeRight) {
        int x = distance;
        
        [path moveToPoint:CGPointMake(x + bevel, 0)];
        [path addLineToPoint:CGPointMake(self.frame.size.width, 0)];
        [path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
        [path addLineToPoint:CGPointMake(x, self.frame.size.height)];
        [path closePath];
    }
    if (direction == SwipeLeft) {
        int x = fabs(distance);
        
        [path moveToPoint:CGPointMake(0, 0)];
        [path addLineToPoint:CGPointMake(self.frame.size.width - x, 0)];
        [path addLineToPoint:CGPointMake(self.frame.size.width - x - bevel, self.frame.size.height)];
        [path addLineToPoint:CGPointMake(0, self.frame.size.height)];
        [path closePath];
    }
    
    
    return path;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint(self.bounds, point) ||
        CGRectContainsPoint([self getScrubber].frame, point))
    {
        return YES;
    }
    return NO;
}

#pragma mark - grid view

- (void)hideExtraUIForGridView {
    [self getPlayButton].hidden = YES;
    [self getScrubber].hidden = YES;
    [self getMuteButton].hidden = YES;
    [self getTimeTextLabel].hidden = YES;
}

- (void)showExtraUIForGridView {
    [self getPlayButton].hidden = NO;
    [self getScrubber].hidden = NO;
    [self getMuteButton].hidden = NO;
    [self getTimeTextLabel].hidden = NO;
}

@end
