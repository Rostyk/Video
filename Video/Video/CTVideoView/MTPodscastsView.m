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
#import "HandyFrame/UIView+LayoutMethods.h"
#import "MTOverlayView.h"

// video takes half of the view
#define VIDEO_AREA_PROPRTION                                                      0.5

#define VIDEO_SWIPE_PERCENT_TO_START_SHOWIN_NEW_INFO_VIEW                         0.4

@interface MTPodscastsView() <MTVideoDelegate, CTVideoViewButtonDelegate, MTOverlayDelegate>
@property (nonatomic, strong) MTVideoView *nextVideoView;
@property (nonatomic, strong) MTVideoView *previousVideoView;
@property (nonatomic, strong) MTVideoView *currentVideoView;

@property (nonatomic, strong) MTInfoView *currentInfoView;
@property (nonatomic, strong) MTInfoView *nextInfoView;

@property (nonatomic) BOOL nextInfoViewAboutToShow;

@property (nonatomic) NSUInteger currentVideoIndex;
@property (nonatomic) CGRect viewFrame;

@property (nonatomic, strong) MTOverlayView *overlayView;
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
    
    self.currentInfoView.frame = CGRectMake(0, self.viewFrame.size.height * VIDEO_AREA_PROPRTION, self.viewFrame.size.width, self.viewFrame.size.height * (1 - VIDEO_AREA_PROPRTION ));
    
    self.overlayView.frame = self.bounds;
}

- (void)commonInit {
    self.viewFrame = CGRectZero;
    
    self.currentVideoView = [self createVideoForIndex:0];
    [self addSubview:self.currentVideoView];
    [self.currentVideoView play];
    
    self.nextVideoView = [self createVideoForIndex:1];
    [self addSubview:self.nextVideoView];
    
    self.currentVideoView.rightSwipeDisabled = YES;
    self.currentVideoView.leftSwipeDisabled = [self.datasource numberOfVideos] == 1;
    [self bringSubviewToFront:self.currentVideoView];
    
    self.currentInfoView = [self createInfoViewWithIndex:0];
    [self addSubview:self.currentInfoView];
    
    //Add overlay listening to all the touches
    self.overlayView = [[MTOverlayView alloc] init];
    self.overlayView.delegate = self;
    [self addSubview:self.overlayView];
}

- (void)keepNextBelowCurrent {
    [self bringSubviewToFront:self.nextVideoView];
    [self bringSubviewToFront:self.currentVideoView];
    [self bringSubviewToFront:self.overlayView];
}

- (void)keepPreviousBelowCurrent {
    [self bringSubviewToFront:self.previousVideoView];
    [self bringSubviewToFront:self.currentVideoView];
    [self bringSubviewToFront:self.overlayView];
}

- (void)updateUserInteractions {
    self.currentVideoView.userInteractionEnabled = true;
    self.previousVideoView.userInteractionEnabled = false;
    self.nextVideoView.userInteractionEnabled = false;
}

#pragma mark - MTVIdeoDelegate

- (void)isMovingManuallyForDistance:(CGFloat)distance
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
    
    [self moveInfoViewFor:distance direction:direction];
}

- (void)isAnimatingForDistance:(CGFloat)distance direction:(SwipeDirection)direction {
     if(direction == SwipeLeft)
        [self moveInfoViewFor:-distance direction:direction];
    
     else
     [self moveInfoViewFor:distance direction:direction];
}

- (void)videoSwiped:(SwipeDirection)direction {
    if (direction == SwipeLeft) {
        self.currentVideoIndex++;
        
        //remove previous view
        [self destroyPreviousVideo];
        
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
        [self destroyNextVideo];
        
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
    [self bringSubviewToFront:self.overlayView];
    
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

#pragma mark - creating/removing video

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

- (void)destroyNextVideo {
    [self.nextVideoView stopWithReleaseVideo:YES];
    [self.nextVideoView removeFromSuperview];
    self.nextVideoView = nil;
    
    [self placeNewInfoView];
}

- (void)destroyPreviousVideo {
    [self.previousVideoView stopWithReleaseVideo:YES];
    [self.previousVideoView removeFromSuperview];
    self.previousVideoView = nil;
    
    [self placeNewInfoView];
}

- (void)placeNewInfoView {
    [self.currentInfoView removeFromSuperview];
    self.currentInfoView = nil;
    
    self.currentInfoView = self.nextInfoView;
    self.nextInfoView = nil;
}

#pragma mark - info view

- (MTInfoView *)createInfoViewWithIndex:(NSUInteger)index {
    MTInfo *info = [self.datasource videoInfoForIndex:index];
    
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"MTInfoView" owner:self options:nil];
    UIView *view = [subviewArray objectAtIndex:0];
    
    view.frame = CGRectMake(0, self.viewFrame.size.height * VIDEO_AREA_PROPRTION, self.viewFrame.size.width, self.viewFrame.size.height * (1 - VIDEO_AREA_PROPRTION ));
    
    MTInfoView *infoView = (MTInfoView *)view;
    infoView.titleLabel.text = info.title;
    infoView.channelLabel.text = info.channel;
    //infoView.channelImage.image = info.channelImage;
    //infoView.bottomImage.image = info.bottomImage;
    
    return infoView;
}

- (void)moveInfoViewFor:(CGFloat)distance direction:(SwipeDirection)direction {
    //Move the current view
    CGFloat x = distance;
    
    CGRect shiftedFrame = self.currentInfoView.frame;
    
    shiftedFrame.origin.x = x;
    
    NSLog(@"Curent info shift: %f", x);
    self.currentInfoView.frame = shiftedFrame;
    
    //Handle the next view
    CGFloat shiftPercent = fabs(distance) / self.frame.size.width;
    
    if (shiftPercent > VIDEO_SWIPE_PERCENT_TO_START_SHOWIN_NEW_INFO_VIEW) {
        if (!self.nextInfoViewAboutToShow) {
            self.nextInfoViewAboutToShow = YES;
            
            NSUInteger nextIndex = [self getNextInfoViewIndexOfDirection:direction];
            self.nextInfoView = [self createInfoViewWithIndex:nextIndex];
            [self addSubview:self.nextInfoView];
            
            self.nextInfoView.moveDirection = direction;
            self.nextInfoView.alpha = 0.0;
        }
        else {
            self.nextInfoView.animationValue = (shiftPercent - VIDEO_SWIPE_PERCENT_TO_START_SHOWIN_NEW_INFO_VIEW) / (1.0 - VIDEO_SWIPE_PERCENT_TO_START_SHOWIN_NEW_INFO_VIEW);
        }
    }
    else {
        if (self.nextInfoViewAboutToShow) {
            [self.nextInfoView removeFromSuperview];
            self.nextInfoViewAboutToShow = NO;
        }
    }
}

- (NSUInteger)getNextInfoViewIndexOfDirection:(SwipeDirection)direction {
    if (direction == SwipeLeft) {
        return self.currentVideoIndex + 1;
    }
    
    return self.currentVideoIndex - 1;
}

#pragma mark - button delegate

- (void)videoView:(CTVideoView *)videoView layoutPlayButton:(UIButton *)playButton
{
    CGRect frame = playButton.frame;
    frame.size = CGSizeMake(100, 60);
    playButton.frame = frame;
    
    [playButton rightInContainer:5 shouldResize:NO];
   	[playButton bottomInContainer:5 shouldResize:NO];
}

- (void)videoView:(CTVideoView *)videoView layoutRetryButton:(UIButton *)retryButton
{
    CGRect frame = retryButton.frame;
    frame.size = CGSizeMake(100, 60);
    retryButton.frame = frame;
    
    [retryButton rightInContainer:5 shouldResize:NO];
   	[retryButton bottomInContainer:5 shouldResize:NO];
}

#pragma mark - overlay view

- (void)touchBegan:(CGFloat)x {
    [self.currentVideoView handleTouchBegan:x];
}

- (void)touchChanged:(CGFloat)x {
    [self.currentVideoView handleTouchChanged:x];
}

- (void)touchEnded:(CGFloat)x {
    [self.currentVideoView handleTouchEnded:x];
}

@end
