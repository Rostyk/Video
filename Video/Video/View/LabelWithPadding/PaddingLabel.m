//
//  PaddingLabel.m
//  Video
//
//  Created by Apple on 9/10/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import "PaddingLabel.h"
@interface PaddingLabel()
@property (nonatomic) UIEdgeInsets insets;
@end

@implementation PaddingLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithCoder:(NSCoder *)aDecoder {
     _insets = UIEdgeInsetsMake(2, 8, 2, 8);
    self = [super initWithCoder:aDecoder];
    return self;
}

- (void)setInsets:(UIEdgeInsets)insets
{
    _insets = insets;
    [self invalidateIntrinsicContentSize] ;
}

- (void)drawTextInRect:(CGRect)rect
{
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.insets)];
}

- (void)resizeHeightToFitText
{
    CGRect frame = [self bounds];
    CGFloat textWidth = frame.size.width - (self.insets.left + self.insets.right);
    
    CGSize newSize = [self.text sizeWithFont:self.font constrainedToSize:CGSizeMake(textWidth, 1000000) lineBreakMode:self.lineBreakMode];
    frame.size.height = newSize.height + self.insets.top + self.insets.bottom;
    self.frame = frame;
}

- (CGSize) intrinsicContentSize
{
    CGSize superSize = [super intrinsicContentSize] ;
    superSize.height += self.insets.top + self.insets.bottom ;
    superSize.width += self.insets.left + self.insets.right ;
    return superSize ;
}

@end
