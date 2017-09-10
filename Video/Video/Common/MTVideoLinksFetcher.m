//
//  MTVideoLinksFetcher.m
//  Video
//
//  Created by Apple on 8/19/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import "MTVideoLinksFetcher.h"
#import "MTGetVideosRequest.h"
#import "MTGetVideosResponse.h"
#import "MTDataModel.h"

@interface MTVideoLinksFetcher()
@property (nonatomic, strong) NSArray *categories;
@end

@implementation MTVideoLinksFetcher

+ (MTVideoLinksFetcher *)fetcher
{
    static MTVideoLinksFetcher *sharedInstance = nil;
    static dispatch_once_t pred;
    
    if (!sharedInstance)
    {
        dispatch_once(&pred, ^{
            sharedInstance = [[MTVideoLinksFetcher alloc] init];
        });
    }
    
    return sharedInstance;
}

- (id)init {
    self = [super init];
    _categories = @[@"nfl", @"nhl", @"nba", @"mlb", @"cfb", @"cbb", @"golf"];
    return self;
}

- (void)fetch:(syncComplete)completion {
    [[MTDataModel sharedDatabaseStorage] clearAllVideos];
    
    dispatch_group_t serviceGroup = dispatch_group_create();
    
    for (NSString *category in self.categories) {
        dispatch_group_enter(serviceGroup);
        MTGetVideosRequest *getVideosRequest = [MTGetVideosRequest new];
        NSUInteger index = [self.categories indexOfObject:category];
        
        getVideosRequest.category = [NSString stringWithFormat:@"%ld", index + 1];
        getVideosRequest.completionBlock = ^(SDRequest *request, SDResult *response) {
            dispatch_group_leave(serviceGroup);
        };
        
        [getVideosRequest run];
    }
    
    dispatch_group_notify(serviceGroup,dispatch_get_main_queue(),^{
        // Now call the final completion block
        completion(true, nil);
    });
}

- (NSString *)categoryForIndex:(NSUInteger)index {
    return [self.categories objectAtIndex:index];
}

@end
