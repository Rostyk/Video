//
//  MTLoginRequest.m
//  Automatize
//
//  Created by Rostyslav.Stepanyak on 3/15/17.
//  Copyright © 2017 Tilf AB. All rights reserved.
//

#import "MTLoginRequest.h"
#import "MTLoginResponse.h"

@implementation MTLoginRequest

- (NSMutableURLRequest *)serviceURLRequest
{
    NSMutableString *configurationString = [NSMutableString stringWithFormat:@"%@/token", [SDUserSettings serviceURL]];
    
    NSMutableURLRequest *networkRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:configurationString]];
    [networkRequest addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSError *error;
    
    NSString *post = [NSString stringWithFormat:@"grant_type=password&username=%@&password=%@", self.username, self.password];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    networkRequest.HTTPBody = postData;
    networkRequest.HTTPMethod = @"POST";
    return networkRequest;
}


- (SDResult *)emptyResponse
{
    return [[MTLoginResponse alloc] init];
}

@end
