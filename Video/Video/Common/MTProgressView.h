//
//  MTProgressView.h
//  Video
//
//  Created by Apple on 7/31/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MTProgressView : NSObject
+ (instancetype)sharedView;
- (void)showInView:(UIView *)view;
- (void)remove;
@end
