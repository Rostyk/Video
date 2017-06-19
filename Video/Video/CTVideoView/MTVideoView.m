//
//  MTVideoView.m
//  Video
//
//  Created by Rostyslav Stepanyak on 6/14/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import "MTVideoView.h"
#define STEP_VALUE                        20
#define LIMIT_DISTANCE                    100

@interface MTVideoView()
@property (nonatomic) CGFloat startX;
@property (nonatomic) CGFloat currentX;

@property (nonatomic, strong) NSTimer *timer;
@end


@implementation MTVideoView

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

    NSLog(@"Distnace: %f", distance);
    
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
    self.clipsToBounds = YES;
}

- (void)clearMask {
    self.layer.mask = nil;
}

- (UIBezierPath *)rectPath:(CGFloat)distance direction:(SwipeDirection)direction{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    if (direction == SwipeRight) {
        int x = distance;
        
        [path moveToPoint:CGPointMake(x + 20, 0)];
        [path addLineToPoint:CGPointMake(self.frame.size.width, 0)];
        [path addLineToPoint:CGPointMake(self.frame.size.width, self.frame.size.height)];
        [path addLineToPoint:CGPointMake(x, self.frame.size.height)];
        [path closePath];
    }
    if (direction == SwipeLeft) {
        int x = fabs(distance);
        
        [path moveToPoint:CGPointMake(0, 0)];
        [path addLineToPoint:CGPointMake(self.frame.size.width - x, 0)];
        [path addLineToPoint:CGPointMake(self.frame.size.width - x - 20, self.frame.size.height)];
        [path addLineToPoint:CGPointMake(0, self.frame.size.height)];
        [path closePath];
    }
    
    
    return path;
}

@end
