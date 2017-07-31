//
//  MTGridView.h
//  Video
//
//  Created by Apple on 7/31/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MTVideoView;

@interface MTGridView : UIView
@property (nonatomic, strong) MTVideoView *firstTileVideoView;
@property (nonatomic, strong) NSString *category;

- (CGSize)firstCellSize;
@end
