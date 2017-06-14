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

typedef enum {
    SwipeLeft = 1,
    SwipeRight
} SwipeDirection;

@interface MTVideoView()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipeGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipeGestureRecognizer;
@property (nonatomic) CGFloat startX;
@property (nonatomic) CGFloat currentX;

@property (nonatomic, strong) NSTimer *timer;
@end


@implementation MTVideoView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setup];
    return self;
}

- (void)setup {
    [self addGestureRecognizer:self.panGestureRecognizer];
    
    [self addGestureRecognizer:self.leftSwipeGestureRecognizer];
    [self addGestureRecognizer:self.rightSwipeGestureRecognizer];
}

#pragma mark - getters and setters
- (UIPanGestureRecognizer *)panGestureRecognizer
{
    if (_panGestureRecognizer == nil) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizedPanRecognizer:)];
        _panGestureRecognizer.maximumNumberOfTouches = 1;
        _panGestureRecognizer.minimumNumberOfTouches = 1;
        _panGestureRecognizer.delegate = self;

    }
    return _panGestureRecognizer;
}

#pragma mark - getters and setters
- (UISwipeGestureRecognizer *)leftSwipeGestureRecognizer
{
    if (_leftSwipeGestureRecognizer == nil) {
        _leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizedLeftSwipeRecognizer:)];
        _leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        _leftSwipeGestureRecognizer.delegate = self;
        
    }
    return _leftSwipeGestureRecognizer;
}

- (UISwipeGestureRecognizer *)rightSwipeGestureRecognizer
{
    if (_rightSwipeGestureRecognizer == nil) {
        _rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizedRightSwipeRecognizer:)];
        _rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        _rightSwipeGestureRecognizer.delegate = self;
        
    }
    return _rightSwipeGestureRecognizer;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - event response
- (void)didRecognizedPanRecognizer:(UIPanGestureRecognizer *)panRecognizer
{
    
    CGPoint velocityPoint = [panRecognizer velocityInView:self];
    
    NSLog(@"[Pan] x: %f", [panRecognizer locationInView:self].x);
    
    switch (panRecognizer.state) {
        case UIGestureRecognizerStateBegan:{
            self.startX = [panRecognizer locationInView:self].x;
            
            CGFloat absoluteX = fabs(velocityPoint.x);
            CGFloat absoluteY = fabs(velocityPoint.y);
            
            break;
        }
            
        case UIGestureRecognizerStateChanged:{
            CGFloat x = [panRecognizer locationInView:self].x;
            self.currentX = x;
            
            CGFloat distance = x - self.startX;
            
            if (distance > 0) {
                [self shrink:distance direction:SwipeRight];
            }
            else {
                [self shrink:fabs(distance) direction:SwipeLeft];
            }
            
            break;
        }
            
        case UIGestureRecognizerStateEnded:{
            CGFloat x = [panRecognizer locationInView:self].x;
            self.currentX = x;
            NSLog(@"[Pan] ended");
            
            CGFloat distance = x - self.startX;
            
            if (distance > 0) {
                [self resolveAnimation:SwipeRight];
            }
            else {
                [self resolveAnimation:SwipeLeft];
            }
            break;
        }
            
        default:
            break;
    }
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
            self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                          target:self
                                                        selector:@selector(restoreByExpandingToLeft)
                                                        userInfo:nil
                                                         repeats:YES];
        }
        if(direction == SwipeLeft) {
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
        
    }
    else {
        [self shrink:distance direction:SwipeRight];
    }
}

- (void)restoreByExpandingToRight {
    self.currentX += STEP_VALUE/2;
    if (self.currentX > self.startX) {
        [self.timer invalidate];
        self.timer = nil;
        
        [self clearMask];
    }
    else {
        CGFloat distance =  self.currentX - self.startX;
        [self shrink:distance direction:SwipeLeft];
    }
}

- (void)animateRight {
    self.currentX += STEP_VALUE;
    CGFloat distance = fabs(self.startX - self.currentX);
    
    if (distance > self.frame.size.width) {
        [self.timer invalidate];
        self.timer = nil;
        
        [self stopWithReleaseVideo:YES];
        [self clearMask];
    }
    else {
        [self shrink:distance direction:SwipeRight];

    }
}

- (void)animateLeft {
    self.currentX -= STEP_VALUE;
    CGFloat distance = fabs(self.startX - self.currentX);
    
    if (distance == self.frame.size.width) {
        [self.timer invalidate];
        self.timer = nil;
        
        [self stopWithReleaseVideo:YES];
        [self clearMask];
    }
    else {
        [self shrink:distance direction:SwipeLeft];
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
