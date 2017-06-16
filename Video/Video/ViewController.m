//
//  ViewController.m
//  Video
//
//  Created by Rostyslav Stepanyak on 6/14/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import "ViewController.h"
#import "MTVideoView.h"
#import "MTPodscastsView.h"

@interface ViewController () <MTPodcastDataSource>
@property (nonatomic, weak) IBOutlet MTPodscastsView *podcastsView;
@property (nonatomic, strong) NSArray *videoURLs;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup {
    self.videoURLs = @[@"http://clips.vorwaerts-gmbh.de/VfE_html5.mp4",
                       @"http://sachinchoolur.github.io/lightGallery/static/videos/video2.mp4",
                       @"http://www.html5videoplayer.net/videos/toystory.mp4",
                       @"http://html5videoformatconverter.com/data/images/happyfit2.mp4"];
    self.podcastsView.datasource = self;
}

#pragma mark - MTPodcastDataSource

- (NSString *)videoUrlForIndex:(NSInteger)index {
    return self.videoURLs[index];
}

- (NSUInteger)numberOfVideos {
    return self.videoURLs.count;
}

@end
