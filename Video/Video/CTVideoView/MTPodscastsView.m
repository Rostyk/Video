//
//  MTPodscastsView.m
//  Video
//
//  Created by Rostyslav Stepanyak on 6/16/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import "MTPodscastsView.h"
#import "MTVideoView.h"

@interface MTPodscastsView() <MTVideoDelegate>
@property (nonatomic, strong) MTVideoView *nextVideoView;
@property (nonatomic, strong) MTVideoView *previousVideoView;
@property (nonatomic, strong) MTVideoView *currentVideoView;

@property (nonatomic, strong) UIView *currentInfoView;
@property (nonatomic, strong) UIView *nextInfoView;

@property (nonatomic) NSUInteger currentVideoIndex;
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

- (void)commonInit {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    self.previousVideoView = [[MTVideoView alloc] initWithFrame:CGRectMake(0, 0, width, 280)];
    self.nextVideoView = [[MTVideoView alloc] initWithFrame:CGRectMake(0, 0, width, 280)];
    self.currentVideoView = [[MTVideoView alloc] initWithFrame:CGRectMake(0, 0, width, 280)];
    
    self.previousVideoView.delegate = self;
    self.currentVideoView.delegate = self;
    self.nextVideoView.delegate = self;
    
    [self addSubview:self.previousVideoView];
    [self addSubview:self.nextVideoView];
    [self addSubview:self.currentVideoView];
    
    [self loadVideoURLs];
}

- (void)keepNextBelowCurrent {
    [self bringSubviewToFront:self.nextVideoView];
    [self bringSubviewToFront:self.currentVideoView];
}

- (void)keepPreviousBelowCurrent {
    [self bringSubviewToFront:self.previousVideoView];
    [self bringSubviewToFront:self.currentVideoView];
}

- (void)loadVideoURLs {
    self.currentVideoView.rightSwipeDisabled = YES;
    self.currentVideoView.leftSwipeDisabled = [self.datasource numberOfVideos] == 1;
    
    self.currentVideoView.videoUrl = [NSURL URLWithString:[self.datasource videoUrlForIndex:0]];
    [self.currentVideoView play];
    
    if ([self.datasource numberOfVideos] > 0) {
        self.nextVideoView.videoUrl = [NSURL URLWithString:[self.datasource videoUrlForIndex:1]];
        [self.nextVideoView prepare];
    }
    
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
    }
    
    if(direction == SwipeRight) {
        [self keepPreviousBelowCurrent];
        [self.previousVideoView play];
        [self.nextVideoView pause];
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
            self.nextVideoView = [[MTVideoView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 280)];
            self.nextVideoView.delegate = self;
            [self addSubview:self.nextVideoView];
            
            self.nextVideoView.videoUrl = [NSURL URLWithString:[self.datasource videoUrlForIndex:self.currentVideoIndex + 1]];
            [self.nextVideoView prepare];
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
        if (self.currentVideoIndex > 0 ) {
            self.previousVideoView = [[MTVideoView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 280)];
            self.previousVideoView.delegate = self;
            [self addSubview:self.previousVideoView];
            
            self.previousVideoView.videoUrl = [NSURL URLWithString:[self.datasource videoUrlForIndex:self.currentVideoIndex - 1]];
            [self.previousVideoView prepare];
        }
        else {
            self.previousVideoView = nil;
            self.currentVideoView.rightSwipeDisabled = YES;
        }
    }
    
    [self performSelector:@selector(updateUserInteractions) withObject:nil afterDelay:0.3];
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

@end
