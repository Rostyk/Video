//
//  MTOverlayView.h
//  Video
//
//  Created by Rostyslav Stepanyak on 6/19/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MTOverlayDelegate
- (void)touchBegan:(CGFloat)x;
- (void)touchChanged:(CGFloat)x;
- (void)touchEnded:(CGFloat)x;
@end

@interface MTOverlayView : UIView
@property (nonatomic, weak) id<MTOverlayDelegate> delegate;
@end
