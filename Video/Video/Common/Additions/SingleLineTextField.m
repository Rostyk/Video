//
//  SingleLineTextField.m
//  SingleLineInput
//
//  Created by Diogo Maximo on 17/10/14.

#import "SingleLineTextField.h"
#define kAnimationOffSet 24
#define kSpaceToLine 0
#define kSpaceToPlaceHolder 0

@implementation SingleLineTextField {
    CGRect frame;
    UIView *lineView;
    NSString *placeHolderString;
    UIColor *lineSelectedColor;
    UIColor *lineNormalColor;
    UIColor *lineDisabledColor;
    UIColor *inputTextColor;
    UIColor *placeHolderColor;
    double animationDuration;
    CGRect aFrame;
    CGRect framePlaceHolder;
    int offSetSizeTextField;
    UIFont *inputFont;
    UIFont *placeHolderFont;
    UIFont *placeHolderFontFloat;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        frame = self.bounds;
        offSetSizeTextField = 0;
        self.lineSelectedColor = [UIColor whiteColor];
        self.lineNormalColor = [UIColor whiteColor];
        self.lineDisabledColor = [UIColor whiteColor];
        self.textColor = [UIColor whiteColor];
        self.delegate = self;
        self.textColor = inputTextColor;
        [self addTarget:self
                 action:@selector(textFieldDidChange:)
       forControlEvents:UIControlEventEditingChanged];
        placeHolderString = self.placeholder;
        self.placeholder = NULL;
        self.font = [UIFont systemFontOfSize:14];
        [self createLineInput];
        [self createPlaceHolderInput];
        self.borderStyle = UITextBorderStyleNone;
        animationDuration = 0.1;
        
        
        aFrame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            self.frame.size.height + offSetSizeTextField);
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.frame = aFrame;
}

- (void)reloadFrameWithFrame:(CGRect)rectFrame {
    aFrame = CGRectMake(rectFrame.origin.x, rectFrame.origin.y, rectFrame.size.width,
                        rectFrame.size.height + offSetSizeTextField);
    self.frame = aFrame;
    [self reloadFrameLineWithWidth];
}

- (void)reloadFrameWithWidth:(CGFloat)width {
    aFrame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width,
                        self.frame.size.height + offSetSizeTextField);
    self.frame = aFrame;
    [self reloadFrameLineWithWidth];
}
- (void)reloadFrameLineWithWidth {
    CALayer *border = [CALayer layer];
    CGFloat borderWidth = 1;
    border.borderColor = [UIColor whiteColor].CGColor;
    border.frame = CGRectMake(0, self.frame.size.height - borderWidth, self.frame.size.width, self.frame.size.height);
    border.borderWidth = borderWidth;
    //[self.layer addSublayer:border];
    //self.layer.masksToBounds = YES;

    self.placeHolderLabel.frame = CGRectMake(frame.origin.x,
                                             frame.origin.y + kSpaceToPlaceHolder,
                                             self.frame.size.width, self.frame.size.height);
    lineView.frame =
    CGRectMake(0, frame.size.height + kSpaceToLine, self.frame.size.width, 1);
}
- (void)createLineInput {
    lineView = [[UIView alloc]
                initWithFrame:CGRectMake(0, frame.size.height + kSpaceToLine,
                                         frame.size.width, 1)];
    lineView.backgroundColor = lineNormalColor;
    [self addSubview:lineView];
}

- (void)createPlaceHolderInput {
    self.placeHolderLabel = [[UILabel alloc]
                        initWithFrame:CGRectMake(frame.origin.x,
                                                 frame.origin.y + kSpaceToPlaceHolder,
                                                 frame.size.width, frame.size.height)];
    self.placeHolderLabel.text = placeHolderString;
    self.placeHolderLabel.font = placeHolderFont;
    self.placeHolderLabel.textColor = [UIColor whiteColor];
    self.placeHolderLabel.alpha = 1;
    self.tintColor = [UIColor colorWithWhite:0.800 alpha:0.800];
    [self addSubview:self.placeHolderLabel];
}

#pragma mark UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.lineDelegate respondsToSelector:@selector(lineTextFieldDidBeginEditing:)]) {
        [self.lineDelegate lineTextFieldDidBeginEditing:textField];
    }
    [UIView animateWithDuration:animationDuration animations:^(void) {
        lineView.backgroundColor = lineSelectedColor;
        self.placeHolderLabel.textColor = placeHolderColor;
        if (textField.text.length == 0) {
            self.placeHolderLabel.frame = CGRectMake(
                                                     self.placeHolderLabel.frame.origin.x,
                                                     self.placeHolderLabel.frame.origin.y - kAnimationOffSet,
                                                     self.placeHolderLabel.frame.size.width,
                                                     self.placeHolderLabel.frame.size.height);
            self.placeHolderLabel.font =
            [UIFont fontWithName:placeHolderFont.fontName size:12];
        }
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.lineDelegate
         respondsToSelector:@selector(lineTextFieldDidEndEditing:)]) {
        [self.lineDelegate lineTextFieldDidEndEditing:textField];
    }
    [UIView animateWithDuration:animationDuration
                     animations:^(void) {
                         lineView.backgroundColor = lineNormalColor;
                         self.placeHolderLabel.textColor = lineDisabledColor;
                         if (textField.text.length == 0) {
                             self.placeHolderLabel.frame = CGRectMake(
                                                                 self.placeHolderLabel.frame.origin.x,
                                                                 self.placeHolderLabel.frame.origin.y + kAnimationOffSet,
                                                                 self.placeHolderLabel.frame.size.width,
                                                                 self.placeHolderLabel.frame.size.height);
                             self.placeHolderLabel.font = placeHolderFont;
                         }
                     }];
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {
    BOOL isShouldChange = YES;
    
    return isShouldChange;
}

- (void)setEnabled:(BOOL)enabled {
    super.enabled = enabled;
    if (!enabled) {
        lineView.hidden = YES;
    } else {
        lineView.hidden = NO;
    }
}

- (void)textFieldDidChange:(id)sender {
    UITextField *textField = (UITextField *)sender;
    // Handle problem with font size when using secure text Entry
    if (textField.text.length > 0) {
        textField.font = inputFont;
    }
}

- (CGRect)placeholderRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 0, 0);
}

#pragma mark - Override default properties
- (void)setLineDisabledColor:(UIColor *)aLineDisabledColor {
    lineDisabledColor = aLineDisabledColor;
}

- (void)setLineNormalColor:(UIColor *)aLineNormalColor {
    lineNormalColor = aLineNormalColor;
}

- (void)setLineSelectedColor:(UIColor *)aLineSelectedColor {
    lineSelectedColor = aLineSelectedColor;
}
- (void)setPlaceHolderSelectedColor:(UIColor *)aPlaceHolderSelectedColor {
    placeHolderColor = aPlaceHolderSelectedColor;
}
- (void)setInputTextColor:(UIColor *)anInputTextColor {
    inputTextColor = anInputTextColor;
    self.textColor = inputTextColor;
}

- (void)setInputPlaceHolderColor:(UIColor *)anInputPlaceHolderColor {
    placeHolderColor = anInputPlaceHolderColor;
    self.placeHolderLabel.textColor = placeHolderColor;
}

- (void)updateText:(NSString *)aText {
    if (aText.length > 0) {
        self.placeHolderLabel.frame = CGRectMake(
                                            self.placeHolderLabel.frame.origin.x,
                                            self.placeHolderLabel.frame.origin.y - kAnimationOffSet,
                                            self.placeHolderLabel.frame.size.width, self.placeHolderLabel.frame.size.height);
        self.placeHolderLabel.font = placeHolderFont;
    }
    
    self.text = aText;
}

- (void)setInputFont:(UIFont *)font
NS_AVAILABLE_IOS(7_0)UI_APPEARANCE_SELECTOR {
    inputFont = font;
    self.font = inputFont;
}

- (void)setPlaceHolderFont:(UIFont *)font
NS_AVAILABLE_IOS(7_0)UI_APPEARANCE_SELECTOR {
    placeHolderFont = font;
    placeHolderFontFloat = [UIFont fontWithName:placeHolderFont.fontName size:14];
    self.placeHolderLabel.font = placeHolderFont;
    
    if (self.text.length > 0) {
        self.placeHolderLabel.font = placeHolderFontFloat;
    }
}

#pragma UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end