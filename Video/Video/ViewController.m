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
#import "MTInfo.h"

@interface ViewController () <MTPodcastDataSource>
@property (nonatomic, weak) IBOutlet MTPodscastsView *podcastsView;
@property (nonatomic, strong) NSArray *videos;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup {
    MTInfo *info1 = [[MTInfo alloc] initWithTitle:@"Video 1"
                                          channel:@"Vevo"
                                     channelImage:nil
                                      bottomImage:nil
                                         videoUrl:@"http://clips.vorwaerts-gmbh.de/VfE_html5.mp4"];
    
    MTInfo *info2 = [[MTInfo alloc] initWithTitle:@"Video 2"
                                          channel:@"Movies"
                                     channelImage:nil
                                      bottomImage:nil
                                         videoUrl:@"http://sachinchoolur.github.io/lightGallery/static/videos/video2.mp4"];
    
    MTInfo *info3 = [[MTInfo alloc] initWithTitle:@"Video 3"
                                          channel:@"Some channel"
                                     channelImage:nil
                                      bottomImage:nil
                                         videoUrl:@"http://techslides.com/demos/sample-videos/small.mp4"];
    
    MTInfo *info4 = [[MTInfo alloc] initWithTitle:@"Video 4"
                                          channel:@"Another channel"
                                     channelImage:nil
                                      bottomImage:nil
                                         videoUrl:@"http://html5videoformatconverter.com/data/images/happyfit2.mp4"];
    self.videos = @[info1, info2, info3, info4];

    self.podcastsView.datasource = self;
}

#pragma mark - MTPodcastDataSource

- (MTInfo *)videoInfoForIndex:(NSInteger)index {
    MTInfo *info = self.videos[index];
    return info;
}

- (NSUInteger)numberOfVideos {
    return self.videos.count;
}

@end
