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
    NSMutableString *configurationString = [NSMutableString stringWithFormat:@"%@/driverLogin", [SDUserSettings serviceURL]];
    
    NSMutableURLRequest *networkRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:configurationString]];
    [networkRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *tmp = [[NSDictionary alloc] initWithObjectsAndKeys:
                         self.email, @"email",
                         self.password, @"password",
                         @"1", @"deviceType",
                         self.deviceId, @"deviceToken",
                         self.lat, @"lat",
                         self.lon, @"long",
                         nil];

    NSError *error;
    NSData *postdata = [NSJSONSerialization dataWithJSONObject:tmp options:0 error:&error];
    
    networkRequest.HTTPBody = postdata;
    networkRequest.HTTPMethod = @"POST";
    return networkRequest;
}

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

- (NSString *)randomStringWithLength: (int) len {
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}

- (SDResult *)emptyResponse
{
    return [[MTLoginResponse alloc] init];
}

@end
