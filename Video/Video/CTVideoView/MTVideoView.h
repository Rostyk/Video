//
//  MTVideoView.h
//  Video
//
//  Created by Rostyslav Stepanyak on 6/14/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import "CTVideoView.h"
#import "Constants.h"
@protocol MTVideoDelegate
- (void)isMovingManuallyForDistance:(CGFloat)distance
                          direction:(SwipeDirection)direction;
- (void)isAnimatingForDistance:(CGFloat)distance
                     direction:(SwipeDirection)direction;
- (void)videoSwiped:(SwipeDirection)direction;
- (void)videoReleasedWithNoSwipeWhileAnimatedTo:(SwipeDirection)direction;
@end

@interface MTVideoView : CTVideoView
@property (nonatomic, weak) id<MTVideoDelegate>delegate;

@property (nonatomic) BOOL leftSwipeDisabled;
@property (nonatomic) BOOL rightSwipeDisabled;
@property (nonatomic, strong) NSString *videoId;

- (void)handleTouchBegan:(CGFloat)x;
- (void)handleTouchChanged:(CGFloat)x;
- (void)handleTouchEnded:(CGFloat)x;

- (void)hideExtraUIForGridView;
- (void)showExtraUIForGridView;

@end
