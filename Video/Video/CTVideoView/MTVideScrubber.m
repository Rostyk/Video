//
//  MTVideScrubber.m
//  Video
//
//  Created by Apple on 7/29/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import "MTVideScrubber.h"

@interface MTVideScrubber()
@property (nonatomic) int currentScale;
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(shrink) object:nil];
    
    self.currentScale = 2;
    [UIView animateWithDuration:0.3 animations:^{
        self.transform = CGAffineTransformMakeScale(1, self.currentScale);
    }];
    
    [self performSelector:@selector(shrink) withObject:nil afterDelay:3.0];
}

- (void)shrink {
    [self shrinkImmediately:false];
}

- (void)shrinkImmediately:(BOOL)immediately {
    //Already shrunk
    if (self.currentScale == 1) {
        return;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(shrink) object:nil];
    
    self.currentScale = 1;
    if (immediately) {
        self.transform = CGAffineTransformMakeScale(1, 0.5);
    }
    else {
        [UIView animateWithDuration:0.3 animations:^{
            self.transform = CGAffineTransformMakeScale(1, 0.5);
        }];
    }
}

- (CGRect)trackRectForBounds:(CGRect)bounds {
    CGRect thinnerBounds = [super trackRectForBounds:bounds];
    thinnerBounds.size.height = 2;
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
    self.minimumTrackTintColor = [UIColor whiteColor];
    self.maximumTrackTintColor = [UIColor grayColor];

    /*(UIGraphicsBeginImageContextWithOptions(CGSizeMake(120, 120), NO, 0.0);
    UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //UIImage *empty = [[UIImage alloc] initWith];
    [self setThumbImage:blank forState:UIControlStateNormal];*/
    
    return self;
}

@end
