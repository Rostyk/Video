//
//  MTInfoView.m
//  Video
//
//  Created by Rostyslav Stepanyak on 6/18/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import "MTInfoView.h"

#define VIEW_DEVIATION                      40
#define TITLE_DEVIATION                     32

@interface MTInfoView()
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *titleLeftMargin;
@property (nonatomic, weak)IBOutlet UIView *dimView;
@property (nonatomic) CGRect originFrame;
@property (nonatomic) CGFloat originalTitleMargin;

@property (nonatomic) BOOL isShareViewShown;
@property (nonatomic, weak) IBOutlet UIButton *shareButton;
@property (nonatomic, weak) IBOutlet UIView *barBelowShareButton;
@property (nonatomic, weak) IBOutlet UIView *shareButtonView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *shareButtonViewHeight;
@end

@implementation MTInfoView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    _originFrame = CGRectZero;
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_originalTitleMargin == 0) {
        _originalTitleMargin = self.titleLeftMargin.constant;
        self.barBelowShareButton.alpha = 0.0;
        self.shareButtonViewHeight.constant = 0;
    }
}

- (void)setAnimationInValue:(CGFloat)animationInValue {
    _animationInValue = animationInValue;
    
    // save original frame
    if (CGRectEqualToRect(self.originFrame, CGRectZero)) {
        self.originFrame = self.frame;
    }
    
    //Fading in
    self.alpha = animationInValue;
    
    //slightly shift the view
    CGRect shiftedFrame = self.originFrame;
    
    if (self.moveDirection == SwipeLeft)
        shiftedFrame.origin.x += (VIEW_DEVIATION - (VIEW_DEVIATION * animationInValue));
    
    if (self.moveDirection == SwipeRight)
        shiftedFrame.origin.x -= (VIEW_DEVIATION - (VIEW_DEVIATION * animationInValue));
    
    self.frame = shiftedFrame;
    
    //dim off
    self.dimView.alpha = 1 - animationInValue;
    
    /*NSLog(@"Title shift: %f", animationInValue);
    if (self.moveDirection == SwipeLeft)
        self.titleLeftMargin.constant = self.originalTitleMargin + TITLE_DEVIATION * (1 - animationInValue);
    
    if (self.moveDirection == SwipeRight)
        self.titleLeftMargin.constant = self.originalTitleMargin - TITLE_DEVIATION * (1 - animationInValue);*/
}

- (IBAction)shareButtonClicked:(id)sender {
    if (self.isShareViewShown) {
        [self hideShareView];
    }
    else {
      [self showShareView];
    }
}

- (void)showShareView {
    self.isShareViewShown = true;
    
    self.shareButtonViewHeight.constant = 108;
    [UIView animateWithDuration:0.6 animations:^{
        self.barBelowShareButton.alpha = 1.0;
        [self layoutSubviews];
    }];
}

- (void)hideShareView {
    self.isShareViewShown = false;
    self.shareButtonViewHeight.constant = 0;
    
    [UIView animateWithDuration:0.6 animations:^{
        self.barBelowShareButton.alpha = 0.0;
        [self layoutSubviews];
    }];
}


- (UIView *)getShareView {
    return _shareButtonView;
}

- (UIButton *)getShareButton {
    return _shareButton;
}

#pragma mark - share button handlers

- (IBAction)facebookButtonClicked:(id)sender {
    [self.shareDelegate facebookShare];
}

- (IBAction)twitterButtonClicked:(id)sender {
    [self.shareDelegate twitterShare];
}

- (IBAction)instagramButtnClicked:(id)sender {
    [self.shareDelegate instagramShare];
}

@end
