//
//  CTVideoView+PlayControlPrivate.m
//  CTVideoView
//
//  Created by casa on 2016/10/12.
//  Copyright © 2016年 casa. All rights reserved.
//

#import "CTVideoView+PlayControlPrivate.h"
#import "CTVideoView+PlayControl.h"
#import "CTVideoView+Time.h"
#import "UIPanGestureRecognizer+ExtraMethods.h"
#import <objc/runtime.h>
#import <MediaPlayer/MediaPlayer.h>

static void * CTVideoViewPlayControlPropertySecondToMove;
static void * CTVideoViewPlayControlPropertyVolumeSlider;

@implementation CTVideoView (PlayControlPrivate)

#pragma mark - getters and setters

- (CGFloat)secondToMove
{
    return [objc_getAssociatedObject(self, &CTVideoViewPlayControlPropertySecondToMove) floatValue];
}

- (void)setSecondToMove:(CGFloat)secondToMove
{
    objc_setAssociatedObject(self, &CTVideoViewPlayControlPropertySecondToMove, @(secondToMove), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UISlider *)volumeSlider
{
    UISlider *volumeSlider = objc_getAssociatedObject(self, &CTVideoViewPlayControlPropertyVolumeSlider);
    if (volumeSlider == nil) {
        for (UIView *view in [self.volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                volumeSlider = (UISlider *)view;
                objc_setAssociatedObject(self, &CTVideoViewPlayControlPropertyVolumeSlider, volumeSlider, OBJC_ASSOCIATION_ASSIGN);
                break;
            }
        }
    }
    return volumeSlider;
}

@end
