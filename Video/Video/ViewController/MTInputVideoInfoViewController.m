//
//  JVFloatLabeledTextFieldViewController.m
//  JVFloatLabeledTextField
//
//  The MIT License (MIT)
//
//  Copyright (c) 2013-2015 Jared Verdi
//  Original Concept by Matt D. Smith
//  http://dribbble.com/shots/1254439--GIF-Mobile-Form-Interaction?list=users
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "MTInputVideoInfoViewController.h"
#import "JVFloatLabeledTextField.h"
#import "JVFloatLabeledTextView.h"
#import "TLTagsControl.h"
#import "MTProgressHUD.h"
#import "MTUploadVideoRequest.h"
#import "MTUploadVideoResponse.h"

const static CGFloat kJVFieldHeight = 44.0f;
const static CGFloat kJVFieldHMargin = 10.0f;

const static CGFloat kJVFieldFontSize = 16.0f;

const static CGFloat kJVFieldFloatingLabelFontSize = 11.0f;

@interface MTInputVideoInfoViewController ()<UITextFieldDelegate, UITextViewDelegate>
@property (nonatomic, strong) TLTagsControl *tagControl;
@property (nonatomic, strong) UIButton *postButton;

@property (nonatomic, strong) JVFloatLabeledTextField *titleField;
@property (nonatomic, strong) JVFloatLabeledTextView *descriptionField;
@end

@implementation MTInputVideoInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Floating Label Demo", @"");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    int width = 80;
    int margin = 20;
    int height = 30;
    
    self.postButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.postButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - width - margin, margin, width, 20);
    self.postButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.postButton.backgroundColor = [UIColor lightGrayColor];
    [self.postButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.postButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    [self.postButton setTitle:@"Upload" forState:UIControlStateNormal];
    self.postButton.userInteractionEnabled = NO;
    [self.postButton addTarget:self action:@selector(pushVideo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.postButton];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(margin)-[_postButton(height)]|" options:0 metrics:@{@"margin": @(margin), @"height": @(height)} views:NSDictionaryOfVariableBindings(_postButton)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(margin)-[_postButton(==width)]|" options:0 metrics:@{@"margin": @([UIScreen mainScreen].bounds.size.width - width - margin), @"width": @(width)} views:NSDictionaryOfVariableBindings(_postButton)]];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor blackColor];
    
    UIColor *placeholderColor = [UIColor colorWithRed:211./255. green:211./255. blue:211./255 alpha:1.0];
    UIColor *textColor = [UIColor whiteColor];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    [self.view setTintColor:[UIColor colorWithRed:141./255. green:141./255. blue:141./255 alpha:1.0]];
#endif
    
    UIColor *floatingLabelColor = [UIColor whiteColor];
    
    self.titleField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectZero];
    [self.titleField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    self.titleField.textColor = textColor;
    self.titleField.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:kJVFieldFontSize];
    self.titleField.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Title for video", @"")
                                    attributes:@{NSForegroundColorAttributeName: placeholderColor}];
    self.titleField.floatingLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:kJVFieldFloatingLabelFontSize];
    self.titleField.floatingLabelTextColor = floatingLabelColor;
    self.titleField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:self.titleField];
    self.titleField.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleField.keepBaseline = YES;

    UIView *div1 = [UIView new];
    div1.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3f];
    [self.view addSubview:div1];
    div1.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self createTags];
    
    TLTagsControl *tagsControl = self.tagControl;

    UIView *div2 = [UIView new];
    div2.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3f];
    [self.view addSubview:div2];
    div2.translatesAutoresizingMaskIntoConstraints = NO;

    UIView *div3 = [UIView new];
    div3.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self.view addSubview:div3];
    div3.translatesAutoresizingMaskIntoConstraints = NO;

    self.descriptionField = [[JVFloatLabeledTextView alloc] initWithFrame:CGRectZero];
    self.descriptionField.delegate = self;
    self.descriptionField.textColor = textColor;
    self.descriptionField.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:kJVFieldFontSize];
    self.descriptionField.placeholder = NSLocalizedString(@"Description for your video", @"");
    self.descriptionField.placeholderTextColor = placeholderColor;
    self.descriptionField.floatingLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:kJVFieldFloatingLabelFontSize];
    self.descriptionField.floatingLabelTextColor = floatingLabelColor;
    self.descriptionField.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.descriptionField];
    self.descriptionField.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(xMargin)-[_titleField]-(xMargin)-|" options:0 metrics:@{@"xMargin": @(kJVFieldHMargin)} views:NSDictionaryOfVariableBindings(_titleField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[div1]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(div1)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(xMargin)-[tagsControl]-(xMargin)-[div2(1)]-(0)-|" options:NSLayoutFormatAlignAllCenterY metrics:@{@"xMargin": @(kJVFieldHMargin)} views:NSDictionaryOfVariableBindings(tagsControl, div2)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[div3]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(div3)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(xMargin)-[_descriptionField]-(xMargin)-|" options:0 metrics:@{@"xMargin": @(kJVFieldHMargin)} views:NSDictionaryOfVariableBindings(_descriptionField)]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(70)-[tagsControl(==tagsHeight)]-[div1(1)]-[_titleField(>=minHeight)]-[div3(1)]-[_descriptionField]|" options:0 metrics:@{@"minHeight": @(kJVFieldHeight), @"tagsHeight" : @(42)} views:NSDictionaryOfVariableBindings(tagsControl, div1, _titleField, div3, _descriptionField)]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tagsControl attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:div2 attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];

    [self.titleField becomeFirstResponder];
    
}

- (void)createTags {
    self.tagControl = [[TLTagsControl alloc]
                                                initWithFrame:CGRectMake(8, 340, self.view.frame.size.width - 16, 42)
                                                andTags:@[@"#nba", @"#phillie"]
                                                withTagsControlMode:TLTagsControlModeEdit];
    
    self.tagControl.tagPlaceholder = @" tags for video";
    UIColor *grayBackgroundColor = [UIColor colorWithRed:102./255. green:102./255. blue:102./255. alpha:1.0];
    
    self.tagControl.tagsBackgroundColor = grayBackgroundColor;
    self.tagControl.tagsDeleteButtonColor = [UIColor whiteColor];
    self.tagControl.tagsTextColor = [UIColor whiteColor];
    
    
    [self.tagControl reloadTagSubviews];
    self.tagControl.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.tagControl];
}

- (BOOL)canUploadVideo {
    if (self.titleField.text.length > 0 && self.descriptionField.text.length > 0) {
        self.postButton.userInteractionEnabled = YES;
        return true;
    }
    
    return false;
}

#pragma mark - UITextFiledDelegate

- (void)textFieldDidChange:(UITextField *)sender {
    if ([self canUploadVideo]) {
        self.postButton.enabled = true;
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    if ([self canUploadVideo]) {
        self.postButton.enabled = true;
    }
}

#pragma mark - Upload video

- (void)pushVideo {
    [self.titleField resignFirstResponder];
    [self.descriptionField resignFirstResponder];
    
    [[MTProgressHUD sharedHUD] showOnView:self.view percentage:false];
    
    __weak typeof(self) weakSelf = self;
    MTUploadVideoRequest *uploadRequest = [MTUploadVideoRequest new];
    uploadRequest.path = self.path;
    uploadRequest.videoData = self.videoData;
    uploadRequest.category = @"nba";
    uploadRequest.title = self.titleField.text;
    uploadRequest.descriptionString = self.descriptionField.text;
    
    uploadRequest.completionBlock = ^(SDRequest *request, SDResult *response) {
        MTUploadVideoResponse *uploadResponse = (MTUploadVideoResponse *)response;
        
        [weakSelf.delegate onVideoUploadedWithId:uploadResponse.videoId];
        [weakSelf dismissViewControllerAnimated:YES completion:NULL];
    };
    
    [uploadRequest run];
}

@end
