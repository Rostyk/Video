//
//  MTPodscastsView.h
//  Video
//
//  Created by Rostyslav Stepanyak on 6/16/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MTVideo;

@protocol MTPodcastDataSource
- (MTVideo *)videoInfoForIndex:(NSInteger)index;
- (NSUInteger)numberOfVideos;
@end

@interface MTPodscastsView : UIView
@property (nonatomic, weak) id<MTPodcastDataSource> datasource;
- (void)switchVideModes;
@end
