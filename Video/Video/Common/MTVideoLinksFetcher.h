//
//  MTVideoLinksFetcher.h
//  Video
//
//  Created by Apple on 8/19/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^syncComplete) (BOOL success, NSError *error);

@interface MTVideoLinksFetcher : NSObject

+ (MTVideoLinksFetcher *)fetcher;
- (void)fetch:(syncComplete)completion;
- (NSString *)categoryForIndex:(NSUInteger)index;
@end
