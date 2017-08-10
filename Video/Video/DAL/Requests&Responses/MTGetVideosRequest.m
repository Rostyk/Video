//
//  MTGetLogsRequest.m
//  Automatize
//
//  Created by Rostyslav.Stepanyak on 3/17/17.
//  Copyright © 2017 Tilf AB. All rights reserved.
//

#import "MTGetVideosRequest.h"
#import "MTGetVideosResponse.h"

@implementation MTGetVideosRequest

- (NSMutableURLRequest *)serviceURLRequest
{
    NSMutableString *configurationString = [NSMutableString stringWithFormat:@"%@/urls/video/category?categoryName=%@", [SDUserSettings serviceURL], self.category];
    
    NSMutableURLRequest *networkRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:configurationString]];
    [networkRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString *bearer = [NSString stringWithFormat:@"Bearer %@", [[MTDataModel sharedDatabaseStorage] getAccessToken]];
    [networkRequest addValue:bearer forHTTPHeaderField:@"Authorization"];
    
    networkRequest.HTTPMethod = @"GET";
    return networkRequest;
}

- (SDResult *)emptyResponse
{
    return [[MTGetVideosResponse alloc] init];
}


@end
