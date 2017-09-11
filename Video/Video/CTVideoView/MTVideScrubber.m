//
//  MTVideScrubber.m
//  Video
//
//  Created by Apple on 7/29/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import "MTVideScrubber.h"

@interface MTVideScrubber()
@property (nonatomic) CGFloat scrubberHeight;
@end

@implementation MTVideScrubber

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)grow {
    [UIView animateWithDuration:2 animations:^{
        CGRect frame = self.frame;
        frame.size.height = 3;
        self.scrubberHeight = 3;
    } completion:NULL];
}

- (CGRect)trackRectForBounds:(CGRect)bounds {
    CGRect thinnerBounds = [super trackRectForBounds:bounds];
    thinnerBounds.size.height = self.scrubberHeight;
    return thinnerBounds;
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    CGRect thinnerBounds = [super thumbRectForBounds:bounds trackRect:rect value:value];
    thinnerBounds.size.width = 1;
    return thinnerBounds;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    self.thumbTintColor = [UIColor clearColor];
    
    /*(UIGraphicsBeginImageContextWithOptions(CGSizeMake(120, 120), NO, 0.0);
    UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //UIImage *empty = [[UIImage alloc] initWith];
    [self setThumbImage:blank forState:UIControlStateNormal];*/
    
    return self;
}

@end
