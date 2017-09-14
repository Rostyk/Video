//
//  MTInfoView.h
//  Video
//
//  Created by Rostyslav Stepanyak on 6/18/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaddingLabel.h"
#import "Constants.h"

@protocol MTInfoShareDelegate <NSObject>
@optional
- (void)facebookShare;
- (void)twitterShare;
- (void)instagramShare;
@end

@interface MTInfoView : UIView
@property (nonatomic, weak) id <MTInfoShareDelegate>shareDelegate;
@property (nonatomic, weak) IBOutlet PaddingLabel *titleLabel;
@property (nonatomic, weak) IBOutlet PaddingLabel *channelLabel;
@property (nonatomic, weak) IBOutlet UIImageView *channelImage;

@property (nonatomic, weak) IBOutlet UIImageView *bottomImage;

// from 0 to 1
@property (nonatomic) CGFloat animationInValue;
@property (nonatomic) SwipeDirection moveDirection;

- (UIView *)getShareView;
- (UIButton *)getShareButton;
@end
