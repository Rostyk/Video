//
//  MTVideoView.h
//  Video
//
//  Created by Rostyslav Stepanyak on 6/14/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import "CTVideoView.h"
typedef enum {
    SwipeLeft = 1,
    SwipeRight
} SwipeDirection;

@protocol MTVideoDelegate
- (void)isMovingForDistance:(CGFloat)distance
                  direction:(SwipeDirection)direction;
- (void)videoSwiped:(SwipeDirection)direction;
- (void)videoReleasedWithNoSwipeWhileAnimatedTo:(SwipeDirection)direction;
@end

@interface MTVideoView : CTVideoView
@property (nonatomic, weak) id<MTVideoDelegate>delegate;

@property (nonatomic) BOOL leftSwipeDisabled;
@property (nonatomic) BOOL rightSwipeDisabled;
@end
