//
//  MTGridViewCell.m
//  Video
//
//  Created by Apple on 7/31/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import "MTGridViewCell.h"
#import "MTVideoView.h"

@interface MTGridViewCell()
@property (nonatomic, strong) MTVideoView *videoView;
@end

@implementation MTGridViewCell

- (void)setupVideoViewWithURL:(NSString *)url {
    if (!_videoView) {
        self.videoView = [[MTVideoView alloc] initWithFrame:self.bounds];
        [self.videoView hideExtraUIForGridView];
        self.videoView.videoContentMode = CTVideoViewContentModeResizeAspectFill;
        self.videoView.videoUrl = [NSURL URLWithString:url];
        //[self.videoView prepare];
        [self.videoView play];
        
        [self addSubview:self.videoView];
    }
}

- (void)dealloc {
    [self.videoView stopWithReleaseVideo:YES];
    [self.videoView removeFromSuperview];
}

- (void)setupVideViewWithExistingVideoView:(MTVideoView *)videoView {
    [self addSubview:videoView];
    
    CGRect resizedFrame = videoView.frame;
    resizedFrame.size.width = self.bounds.size.width;
    resizedFrame.size.height = self.bounds.size.height;
    
    [UIView animateWithDuration:0.5
                     animations:^{
                         videoView.frame = resizedFrame;
                     }
                     completion:NULL];
}



@end
