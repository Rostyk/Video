//
//  MTOverlayView.m
//  Video
//
//  Created by Rostyslav Stepanyak on 6/19/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import "MTOverlayView.h"
#import "CTVideoView.h"
#import "MTInfoView.h"

@interface MTOverlayView()<UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *leftSwipeGestureRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer *rightSwipeGestureRecognizer;

@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@end

@implementation MTOverlayView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setup];
    return self;
}

- (id)init {
    self = [super init];
    [self setup];
    return self;
}

- (void)setup {
    [self addGestureRecognizer:self.panGestureRecognizer];
    [self addGestureRecognizer:self.tapGestureRecognizer];
    [self addGestureRecognizer:self.leftSwipeGestureRecognizer];
    [self addGestureRecognizer:self.rightSwipeGestureRecognizer];
}

#pragma mark - getters and setters

- (UIPanGestureRecognizer *)panGestureRecognizer
{
    if (_panGestureRecognizer == nil) {
        _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizedPanRecognizer:)];
        _panGestureRecognizer.minimumNumberOfTouches = 1;
        _panGestureRecognizer.delegate = self;
        
    }
    return _panGestureRecognizer;
}

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

- (UITapGestureRecognizer *)tapGestureRecognizer
{
    if (_tapGestureRecognizer == nil) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeTapRecognizer:)];
        _tapGestureRecognizer.delegate = self;
        
    }
    return _tapGestureRecognizer;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - event response

- (void)didRecognizedPanRecognizer:(UIPanGestureRecognizer *)panRecognizer
{
    //CGPoint velocityPoint = [panRecognizer velocityInView:self];
    
    //NSLog(@"[Pan] x: %f", [panRecognizer locationInView:self].x);
    switch (panRecognizer.state) {
            case UIGestureRecognizerStateBegan:{
                CGFloat x = [panRecognizer locationInView:self].x;
                [self.delegate touchBegan:x];
                break;
            }
            
            case UIGestureRecognizerStateChanged:{
                CGFloat x = [panRecognizer locationInView:self].x;
                [self.delegate touchChanged:x];
                break;
            }
            
            case UIGestureRecognizerStateEnded:{
                CGFloat x = [panRecognizer locationInView:self].x;
                [self.delegate touchEnded:x];
                break;
            }
            
        default:
            break;
    }
}

- (void)didRecognizeTapRecognizer:(UITapGestureRecognizer *)tapRecognizer {
    if(tapRecognizer.state != UIGestureRecognizerStateRecognized)
        return;
    
    CGPoint touchPoint = [tapRecognizer locationInView:self];
    [[self superview] convertPoint:touchPoint toView:[self superview]];
    
    for (UIView* subview in self.superview.subviews ) {
        if ([subview isKindOfClass:[CTVideoView class]]) {
            CTVideoView *videoView = (CTVideoView *)subview;
            
            if (CGRectContainsPoint(videoView.frame, touchPoint)) {
                [self.delegate didTapOnVideo];
                break;
            }
            else {
                NSLog(@"tap outside video");
            }
        }
    }
    
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    //NSLog(@"Passing all touches to the next view (if any), in the view stack.");
    for (UIView* subview in self.superview.subviews ) {
        if ([subview isKindOfClass:[CTVideoView class]]) {
            CTVideoView *videoView = (CTVideoView *)subview;
            UIButton *playButton = [videoView getPlayButton];
            UIButton *muteButton = [videoView getMuteButton];
            UISlider *scrubber = [videoView getScrubber];
            if ([playButton hitTest:[self convertPoint:point toView:playButton] withEvent:event] != nil ||
                [muteButton hitTest:[self convertPoint:point toView:muteButton] withEvent:event] != nil ||
                [scrubber hitTest:[self convertPoint:point toView:scrubber] withEvent:event] != nil) {
                return NO;
            }
        }
        
        if ([subview isKindOfClass:[MTInfoView class]]) {
            MTInfoView *infoView = (MTInfoView *)subview;
            UIButton *shareButton = [infoView getShareButton];
            UIView *shareView = [infoView getShareView];
            
            if ([shareButton hitTest:[self convertPoint:point toView:shareButton] withEvent:event] != nil ||
                [shareView hitTest:[self convertPoint:point toView:shareView] withEvent:event] != nil) {
                return NO;
            }
        }
    }
    return YES;
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

@end
