//
//  ViewController.m
//  Video
//
//  Created by Rostyslav Stepanyak on 6/14/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import "ViewController.h"
#import "MTVideoView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
}

- (void)setup {
    CGRect videoFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 300);
    MTVideoView *videoView1 = [[MTVideoView alloc] initWithFrame:videoFrame];
    
    [self.view addSubview:videoView1];
    
    videoView1.videoUrl = [NSURL URLWithString:@"http://clips.vorwaerts-gmbh.de/VfE_html5.mp4"];
    videoView1.userInteractionEnabled = false;

    [videoView1 play];
    
    
    CGRect videoFrame2 = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 300);
    MTVideoView *videoView2 = [[MTVideoView alloc] initWithFrame:videoFrame2];
    
    [self.view addSubview:videoView2];
    
    videoView2.videoUrl = [NSURL URLWithString:@"http://sachinchoolur.github.io/lightGallery/static/videos/video2.mp4"];
    [videoView2 play];
    
    [self.view bringSubviewToFront:videoView2];
}


@end
