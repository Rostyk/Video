//
//  MTInfoView.h
//  Video
//
//  Created by Rostyslav Stepanyak on 6/18/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface MTInfoView : UIView
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *channelLabel;
@property (nonatomic, weak) IBOutlet UIImageView *channelImage;

@property (nonatomic, weak) IBOutlet UIImageView *bottomImage;

// from 0 to 1
@property (nonatomic) CGFloat animationInValue;
@property (nonatomic) SwipeDirection moveDirection;
@end
