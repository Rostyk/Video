//
//  MTPodscastsView.m
//  Video
//
//  Created by Rostyslav Stepanyak on 6/16/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import "MTPodscastsView.h"
#import "MTVideoView.h"
#import "MTInfo.h"
#import "MTInfoView.h"

// video takes half of the view
#define VIDEO_AREA_PROPRTION                      0.5

@interface MTPodscastsView() <MTVideoDelegate>
@property (nonatomic, strong) MTVideoView *nextVideoView;
@property (nonatomic, strong) MTVideoView *previousVideoView;
@property (nonatomic, strong) MTVideoView *currentVideoView;

@property (nonatomic, strong) UIView *currentInfoView;
@property (nonatomic, strong) UIView *nextInfoView;

@property (nonatomic) NSUInteger currentVideoIndex;
@property (nonatomic) CGRect viewFrame;
@end

@implementation MTPodscastsView

- (id)initWithFrame:(CGRect)aRect
{
    if ((self = [super initWithFrame:aRect])) {
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
    }
    return self;
}

- (void)setDatasource:(id<MTPodcastDataSource>)datasource {
    _datasource = datasource;
    [self commonInit];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (CGRectEqualToRect(self.viewFrame, CGRectZero)) {
        self.viewFrame = self.frame;
        
        [self updateVideoFrames];
    }
}

- (void)updateVideoFrames {
    self.previousVideoView.frame = CGRectMake(0, 0, self.viewFrame.size.width, self.viewFrame.size.height * VIDEO_AREA_PROPRTION);
    self.currentVideoView.frame = CGRectMake(0, 0, self.viewFrame.size.width, self.viewFrame.size.height * VIDEO_AREA_PROPRTION);
    self.nextVideoView.frame = CGRectMake(0, 0, self.viewFrame.size.width, self.viewFrame.size.height * VIDEO_AREA_PROPRTION);
}

- (void)commonInit {
    self.viewFrame = CGRectZero;
    
    self.currentVideoView = [self createVideoForIndex:0];
    [self addSubview:self.currentVideoView];
    
    self.nextVideoView = [self createVideoForIndex:1];
    [self addSubview:self.nextVideoView];
    
    self.currentVideoView.rightSwipeDisabled = YES;
    self.currentVideoView.leftSwipeDisabled = [self.datasource numberOfVideos] == 1;
    [self bringSubviewToFront:self.currentVideoView];
    
    [self.currentVideoView play];
}

- (void)keepNextBelowCurrent {
    [self bringSubviewToFront:self.nextVideoView];
    [self bringSubviewToFront:self.currentVideoView];
}

- (void)keepPreviousBelowCurrent {
    [self bringSubviewToFront:self.previousVideoView];
    [self bringSubviewToFront:self.currentVideoView];
}

- (void)updateUserInteractions {
    self.currentVideoView.userInteractionEnabled = true;
    self.previousVideoView.userInteractionEnabled = false;
    self.nextVideoView.userInteractionEnabled = false;
}

#pragma mark - MTVIdeoDelegate

- (void)isMovingForDistance:(CGFloat)distance
                  direction:(SwipeDirection)direction {
    
    if (direction == SwipeLeft) {
        [self keepNextBelowCurrent];
        [self.nextVideoView play];
        [self.previousVideoView pause];
        
        self.previousVideoView.hidden = YES;
        self.nextVideoView.hidden = NO;
        self.currentVideoView.hidden = NO;
    }
    
    if(direction == SwipeRight) {
        [self keepPreviousBelowCurrent];
        [self.previousVideoView play];
        [self.nextVideoView pause];
        
        self.nextVideoView.hidden = YES;
        self.previousVideoView.hidden = NO;
        self.currentVideoView.hidden = NO;
    }
}

- (void)videoSwiped:(SwipeDirection)direction {
    if (direction == SwipeLeft) {
        self.currentVideoIndex++;
        
        //remove previous view
        [self.previousVideoView stopWithReleaseVideo:YES];
        [self.previousVideoView removeFromSuperview];
        self.previousVideoView = nil;
        
        //shift video
        self.previousVideoView = self.currentVideoView;
        self.currentVideoView = self.nextVideoView;
        
        //loading next view
        if ([self.datasource numberOfVideos] > self.currentVideoIndex + 1) {
            self.nextVideoView = [self createVideoForIndex:self.currentVideoIndex + 1];
            [self addSubview:self.nextVideoView];
        }
        else {
            self.nextVideoView = nil;
            self.currentVideoView.leftSwipeDisabled = YES;
        }
    }
    
    if(direction == SwipeRight) {
        self.currentVideoIndex--;
        
        //remove next view
        [self.nextVideoView stopWithReleaseVideo:YES];
        [self.nextVideoView removeFromSuperview];
        self.nextVideoView = nil;
        
        //shift to previous
        self.nextVideoView = self.currentVideoView;
        self.currentVideoView = self.previousVideoView;
        
        //loading previous view
        if (self.currentVideoIndex > 0) {
            self.previousVideoView = [self createVideoForIndex:self.currentVideoIndex - 1];
            [self addSubview:self.previousVideoView];
        }
        else {
            self.previousVideoView = nil;
            self.currentVideoView.rightSwipeDisabled = YES;
        }
    }
    
    [self updateUserInteractions];
    [self bringSubviewToFront:self.currentVideoView];
    
    self.currentVideoView.rightSwipeDisabled = self.currentVideoIndex == 0;
    self.currentVideoView.leftSwipeDisabled = (self.currentVideoIndex + 1) == [self.datasource numberOfVideos];
}

- (void)videoReleasedWithNoSwipeWhileAnimatedTo:(SwipeDirection)direction {
    if (direction == SwipeLeft) {
        [self.nextVideoView pause];
    }
    
    if (direction == SwipeRight) {
        [self.previousVideoView pause];
    }
}

#pragma mark - creating new video

- (MTVideoView *)createVideoForIndex:(NSUInteger)index {
    MTVideoView *videoView = [[MTVideoView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.viewFrame.size.height * VIDEO_AREA_PROPRTION)];
    videoView.delegate = self;
    videoView.videoContentMode = CTVideoViewContentModeResizeAspectFill;
    
    if (index < [self.datasource numberOfVideos]) {
        MTInfo *info = [self.datasource videoInfoForIndex:index];
        videoView.videoUrl = [NSURL URLWithString:info.videoURL];
        [videoView prepare];
    }
    
    return videoView;
}

#pragma mark - info view

- (MTInfoView *)infoViewWithInfo:(MTInfo *)info {
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"Your_nib_name" owner:self options:nil];
    UIView *view = [subviewArray objectAtIndex:0];
    return (MTInfoView *)view;
}

@end
