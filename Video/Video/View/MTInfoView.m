//
//  MTInfoView.m
//  Video
//
//  Created by Rostyslav Stepanyak on 6/18/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import "MTInfoView.h"

@interface MTInfoView()
@property (nonatomic, weak)IBOutlet UIView *dimView;
@end

@implementation MTInfoView

- (void)setAnimationValue:(CGFloat)animationValue {
    _animationValue = animationValue;
    
    self.dimView.alpha = 1 - animationValue;
}

@end
