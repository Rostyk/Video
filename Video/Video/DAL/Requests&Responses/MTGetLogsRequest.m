//
//  MTGetLogsRequest.m
//  Automatize
//
//  Created by Rostyslav.Stepanyak on 3/17/17.
//  Copyright © 2017 Tilf AB. All rights reserved.
//

#import "MTGetLogsRequest.h"
#import "MTGetLogsResponse.h"

@implementation MTGetLogsRequest

- (NSMutableURLRequest *)serviceURLRequest
{
    NSMutableString *configurationString = [NSMutableString stringWithFormat:@"%@/logOfDriver", [SDUserSettings serviceURL]];
    
    NSMutableURLRequest *networkRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:configurationString]];
    [networkRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *tmp = [[NSDictionary alloc] initWithObjectsAndKeys:
                         /*[[MTDataModel sharedDatabaseStorage] getAccessToken]*/@"", @"accessToken",
                         nil];
    
    NSError *error;
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
    
    networkRequest.HTTPBody = postdata;
    networkRequest.HTTPMethod = @"POST";
    return networkRequest;
}

- (SDResult *)emptyResponse
{
    return [[MTGetLogsResponse alloc] init];
}


@end
