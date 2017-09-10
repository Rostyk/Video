//
//  PaddingLabel.m
//  Video
//
//  Created by Apple on 9/10/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import "PaddingLabel.h"

@implementation PaddingLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {0, 8, 0, 8};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
