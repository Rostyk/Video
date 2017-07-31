//
//  CBStoreHouseRefreshControl.h
//  CBStoreHouseRefreshControl
//
//  Created by coolbeet on 10/30/14.
//  Copyright (c) 2014 Suyu Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CBStoreHouseRefreshControl : UIView
extern NSString *const startPointKey;
extern NSString *const endPointKey;
extern NSString *const xKey;
extern NSString *const yKey;

typedef enum {
    CBStoreHouseRefreshControlStateIdle = 0,
    CBStoreHouseRefreshControlStateRefreshing = 1,
    CBStoreHouseRefreshControlStateDisappearing = 2
} CBStoreHouseRefreshControlState;

@property (nonatomic) CBStoreHouseRefreshControlState state;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) CGFloat animationProgress;

//@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *view;
@property (nonatomic, strong) NSArray *barItems;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) id target;
@property (nonatomic) SEL action;

@property (nonatomic) CGFloat dropHeight;
@property (nonatomic) CGFloat originalTopContentInset;
@property (nonatomic) CGFloat disappearProgress;
@property (nonatomic) CGFloat internalAnimationFactor;
@property (nonatomic) int horizontalRandomness;
@property (nonatomic) BOOL reverseLoadingAnimation;

+ (CBStoreHouseRefreshControl*)attachToScrollView:(UIScrollView *)scrollView
                                           target:(id)target
                                    refreshAction:(SEL)refreshAction
                                            plist:(NSString *)plist;

+ (CBStoreHouseRefreshControl*)attachToScrollView:(UIScrollView *)scrollView
                                           target:(id)target
                                    refreshAction:(SEL)refreshAction
                                            plist:(NSString *)plist
                                            color:(UIColor*)color
                                        lineWidth:(CGFloat)lineWidth
                                       dropHeight:(CGFloat)dropHeight
                                            scale:(CGFloat)scale
                             horizontalRandomness:(CGFloat)horizontalRandomness
                          reverseLoadingAnimation:(BOOL)reverseLoadingAnimation
                          internalAnimationFactor:(CGFloat)internalAnimationFactor;
+ (CBStoreHouseRefreshControl*)attachToView:(UIView *)view
                                     target:(id)target
                              refreshAction:(SEL)refreshAction
                                      plist:(NSString *)plist
                                      color:(UIColor*)color
                                  lineWidth:(CGFloat)lineWidth
                                 dropHeight:(CGFloat)dropHeight
                                      scale:(CGFloat)scale
                       horizontalRandomness:(CGFloat)horizontalRandomness
                    reverseLoadingAnimation:(BOOL)reverseLoadingAnimation
                    internalAnimationFactor:(CGFloat)internalAnimationFactor;


- (void)start;
- (void)stop;

@end
