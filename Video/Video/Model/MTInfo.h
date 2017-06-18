//
//  MTInfo.h
//  Video
//
//  Created by Rostyslav Stepanyak on 6/18/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MTInfo : NSObject

- (id)initWithTitle:(NSString *)title
            channel:(NSString *)channel
       channelImage:(UIImage *)channelImage
        bottomImage:(UIImage *)bottomImage
           videoUrl:(NSString *)videoURL;

@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *channel;

@property (nonatomic, readonly) UIImage *channelImage;
@property (nonatomic, readonly) UIImage *bottomImage;

@property (nonatomic, readonly) NSString *videoURL;

@end
