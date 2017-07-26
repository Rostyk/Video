//
//  SingleLineTextField.h
//  SingleLineInput
//
//  Created by Diogo Maximo on 17/10/14.
//

#import <UIKit/UIKit.h>

@protocol SingleLineTextFieldDelegate <NSObject>

- (void)lineTextFieldDidBeginEditing:(UITextField *)textField;
- (void)lineTextFieldDidEndEditing:(UITextField *)textField;
- (BOOL)lineTextField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

@end

@interface SingleLineTextField : UITextField<UITextFieldDelegate>

@property (nonatomic, strong) UILabel *placeHolderLabel;

- (void)textFieldDidEndEditing:(UITextField *)textField;
- (void)setLineDisabledColor:(UIColor *)aLineDisabledColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
- (void)setLineNormalColor:(UIColor *)aLineNormalColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
- (void)setLineSelectedColor:(UIColor *)aLineSelectedColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
- (void)setPlaceHolderSelectedColor:(UIColor *)aPlaceHolderSelectedColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
- (void)setInputTextColor:(UIColor *)anInputTextColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
- (void)setInputPlaceHolderColor:(UIColor *)anInputPlaceHolderColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
- (void)setPlaceHolderFont:(UIFont *)font NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
- (void)setInputFont:(UIFont *)font NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR;
- (void)updateText:(NSString *) aText;
@property (nonatomic, weak) id <SingleLineTextFieldDelegate> lineDelegate;

- (void)reloadFrameWithWidth:(CGFloat)width;
- (void)reloadFrameWithFrame:(CGRect)rectFrame;

@end
