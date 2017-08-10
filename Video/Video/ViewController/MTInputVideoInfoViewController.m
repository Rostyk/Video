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

const static CGFloat kJVFieldHeight = 44.0f;
const static CGFloat kJVFieldHMargin = 10.0f;

const static CGFloat kJVFieldFontSize = 16.0f;

const static CGFloat kJVFieldFloatingLabelFontSize = 11.0f;

@interface MTInputVideoInfoViewController ()
@property (nonatomic, strong) TLTagsControl *tagControl;
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
    
    UIButton *postButton = [UIButton buttonWithType:UIButtonTypeSystem];
    postButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - width - margin, margin, width, 20);
    postButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    postButton.backgroundColor = [UIColor lightGrayColor];
    [postButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    postButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    [postButton setTitle:@"Upload" forState:UIControlStateNormal];
    [self.view addSubview:postButton];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(margin)-[postButton(height)]|" options:0 metrics:@{@"margin": @(margin), @"height": @(height)} views:NSDictionaryOfVariableBindings(postButton)]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(margin)-[postButton(==width)]|" options:0 metrics:@{@"margin": @([UIScreen mainScreen].bounds.size.width - width - margin), @"width": @(width)} views:NSDictionaryOfVariableBindings(postButton)]];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor blackColor];
    
    UIColor *placeholderColor = [UIColor colorWithRed:211./255. green:211./255. blue:211./255 alpha:1.0];
    UIColor *textColor = [UIColor whiteColor];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    [self.view setTintColor:[UIColor colorWithRed:141./255. green:141./255. blue:141./255 alpha:1.0]];
#endif
    
    UIColor *floatingLabelColor = [UIColor whiteColor];
    
    JVFloatLabeledTextField *titleField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectZero];
    titleField.textColor = textColor;
    titleField.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:kJVFieldFontSize];
    titleField.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Title for video", @"")
                                    attributes:@{NSForegroundColorAttributeName: placeholderColor}];
    titleField.floatingLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:kJVFieldFloatingLabelFontSize];
    titleField.floatingLabelTextColor = floatingLabelColor;
    titleField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.view addSubview:titleField];
    titleField.translatesAutoresizingMaskIntoConstraints = NO;
    titleField.keepBaseline = YES;

    UIView *div1 = [UIView new];
    div1.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3f];
    [self.view addSubview:div1];
    div1.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self createTags];

    //JVFloatLabeledTextField *priceField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectZero];
    /*priceField.textColor = textColor;
    
    priceField.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    priceField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Tag", @"")
                                                                       attributes:@{NSForegroundColorAttributeName: placeholderColor}];
    priceField.floatingLabelFont = [UIFont boldSystemFontOfSize:kJVFieldFloatingLabelFontSize];
    priceField.floatingLabelTextColor = floatingLabelColor;
    [self.view addSubview:priceField];
    
    priceField.translatesAutoresizingMaskIntoConstraints = NO;*/
    
    TLTagsControl *tagsControl = self.tagControl;

    UIView *div2 = [UIView new];
    div2.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3f];
    [self.view addSubview:div2];
    div2.translatesAutoresizingMaskIntoConstraints = NO;
    
    /*JVFloatLabeledTextField *locationField = [[JVFloatLabeledTextField alloc] initWithFrame:CGRectZero];
    locationField.textColor = textColor;
    locationField.font = [UIFont systemFontOfSize:kJVFieldFontSize];
    locationField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Specific Location (optional)", @"")
                                                                          attributes:@{NSForegroundColorAttributeName: placeholderColor}];
    locationField.floatingLabelFont = [UIFont boldSystemFontOfSize:kJVFieldFloatingLabelFontSize];
    locationField.floatingLabelTextColor = floatingLabelColor;
    [self.view addSubview:locationField];
    locationField.translatesAutoresizingMaskIntoConstraints = NO;*/

    UIView *div3 = [UIView new];
    div3.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3f];
    [self.view addSubview:div3];
    div3.translatesAutoresizingMaskIntoConstraints = NO;

    JVFloatLabeledTextView *descriptionField = [[JVFloatLabeledTextView alloc] initWithFrame:CGRectZero];
    descriptionField.textColor = textColor;
    descriptionField.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:kJVFieldFontSize];
    descriptionField.placeholder = NSLocalizedString(@"Description for your video", @"");
    descriptionField.placeholderTextColor = placeholderColor;
    descriptionField.floatingLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:kJVFieldFloatingLabelFontSize];
    descriptionField.floatingLabelTextColor = floatingLabelColor;
    descriptionField.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:descriptionField];
    descriptionField.translatesAutoresizingMaskIntoConstraints = NO;

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(xMargin)-[titleField]-(xMargin)-|" options:0 metrics:@{@"xMargin": @(kJVFieldHMargin)} views:NSDictionaryOfVariableBindings(titleField)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[div1]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(div1)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(xMargin)-[tagsControl]-(xMargin)-[div2(1)]-(0)-|" options:NSLayoutFormatAlignAllCenterY metrics:@{@"xMargin": @(kJVFieldHMargin)} views:NSDictionaryOfVariableBindings(tagsControl, div2)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[div3]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(div3)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(xMargin)-[descriptionField]-(xMargin)-|" options:0 metrics:@{@"xMargin": @(kJVFieldHMargin)} views:NSDictionaryOfVariableBindings(descriptionField)]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(70)-[tagsControl(==tagsHeight)]-[div1(1)]-[titleField(>=minHeight)]-[div3(1)]-[descriptionField]|" options:0 metrics:@{@"minHeight": @(kJVFieldHeight), @"tagsHeight" : @(42)} views:NSDictionaryOfVariableBindings(tagsControl, div1, titleField, div3, descriptionField)]];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:tagsControl attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:div2 attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];
    
    /*[self.view addConstraint:[NSLayoutConstraint constraintWithItem:tagsControl attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:locationField attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0.0]];*/

    [titleField becomeFirstResponder];
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
