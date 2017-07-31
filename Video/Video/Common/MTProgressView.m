//
//  MTProgressView.m
//  Video
//
//  Created by Apple on 7/31/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import "MTProgressView.h"
#import "CBStoreHouseRefreshControl.h"
#import "BarItem.h"

@interface MTProgressView()
@property (nonatomic, strong) CBStoreHouseRefreshControl *refreshControl;
@end

@implementation MTProgressView

+ (instancetype)sharedView {
    static MTProgressView *_sharedView = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedView = [[self alloc] init];
    });
    
    return _sharedView;
}

- (id)init {
    self = [super init];
    [self setup];
    return self;
}

- (void)setup {
    self.refreshControl = [[CBStoreHouseRefreshControl alloc] init];
    
    CGFloat scale = 1;
    CGFloat lineWidth = 2.5;
    self.refreshControl.dropHeight = 80;
    self.refreshControl.horizontalRandomness = 150;
    //refreshControl.view = view;
    self.refreshControl.target = self;
    self.refreshControl.action = @selector(refresh);
    self.refreshControl.reverseLoadingAnimation = NO;
    self.refreshControl.internalAnimationFactor = 0.7;
    //[view addSubview:refreshControl];
    
    CGFloat width = 0;
    CGFloat height = 0;
    NSDictionary *rootDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TLOS" ofType:@"plist"]];
    NSArray *startPoints = [rootDictionary objectForKey:startPointKey];
    NSArray *endPoints = [rootDictionary objectForKey:endPointKey];
    for (int i=0; i<startPoints.count; i++) {
        
        CGPoint startPoint = CGPointFromString(startPoints[i]);
        CGPoint endPoint = CGPointFromString(endPoints[i]);
        
        if (startPoint.x > width) width = startPoint.x;
        if (endPoint.x > width) width = endPoint.x + 2;
        if (startPoint.y > height) height = startPoint.y;
        if (endPoint.y > height) height = endPoint.y;
    }
    self.refreshControl.frame = CGRectMake(0, 0, width, height);
    
    // Create bar items
    NSMutableArray *mutableBarItems = [[NSMutableArray alloc] init];
    for (int i=0; i<startPoints.count; i++) {
        
        CGPoint startPoint = CGPointFromString(startPoints[i]);
        CGPoint endPoint = CGPointFromString(endPoints[i]);
        
        BarItem *barItem = [[BarItem alloc] initWithFrame:self.refreshControl.frame startPoint:startPoint endPoint:endPoint color:[UIColor whiteColor] lineWidth:lineWidth];
        barItem.tag = i;
        barItem.alpha = 0;
        [mutableBarItems addObject:barItem];
        [self.refreshControl addSubview:barItem];
        
        [barItem setHorizontalRandomness:self.refreshControl.horizontalRandomness dropHeight:self.refreshControl.dropHeight];
    }
    
    self.refreshControl.barItems = [NSArray arrayWithArray:mutableBarItems];
    self.refreshControl.frame = CGRectMake(0, 0, width, height);
    self.refreshControl.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, 0);
    for (BarItem *barItem in self.refreshControl.barItems) {
        [barItem setupWithFrame:self.refreshControl.frame];
    }
    
    self.refreshControl.transform = CGAffineTransformMakeScale(scale, scale);
}

- (void)showInView:(UIView *)view {
    [self.refreshControl removeFromSuperview];
    
    self.refreshControl.view = view;
    [view addSubview:self.refreshControl];
    
    [self.refreshControl start];
}

- (void)remove {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.9
                     animations:^{
                         self.refreshControl.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [weakSelf.refreshControl removeFromSuperview];
                         weakSelf.refreshControl.alpha = 1.0;
                     }];
}

@end
