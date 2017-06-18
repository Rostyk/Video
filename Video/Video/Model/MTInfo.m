//
//  MTInfo.m
//  Video
//
//  Created by Rostyslav Stepanyak on 6/18/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import "MTInfo.h"

@implementation MTInfo

- (id)initWithTitle:(NSString *)title
            channel:(NSString *)channel
       channelImage:(UIImage *)channelImage
        bottomImage:(UIImage *)bottomImage
           videoUrl:(NSString *)videoURL {
    self = [super init];
    _title = title;
    _channel = channel;
    _channelImage = channelImage;
    _bottomImage = bottomImage;
    _videoURL = videoURL;
    return self;
}

@end
