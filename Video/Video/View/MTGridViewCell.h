//
//  MTGridViewCell.h
//  Video
//
//  Created by Apple on 7/31/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MTVideoView;

@interface MTGridViewCell : UICollectionViewCell
- (void)setupVideoViewWithURL:(NSString *)url;
- (void)setupVideViewWithExistingVideoView:(MTVideoView *)videoView;
@end
