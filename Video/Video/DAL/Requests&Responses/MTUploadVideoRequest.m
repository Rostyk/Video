//
//  MTUploadSandTicketRequest.m
//  Automatize
//
//  Created by Rostyslav.Stepanyak on 3/17/17.
//  Copyright © 2017 Tilf AB. All rights reserved.
//

#import "MTUploadVideoRequest.h"
#import "MTUploadVideoResponse.h"
#import "SDMultipartRequestUtility.h"

@interface MTUploadVideoRequest()
@property (nonatomic, strong) SDMultipartRequestUtility *utility;
@end

@implementation MTUploadVideoRequest

- (NSMutableURLRequest *)serviceURLRequest
{
    NSMutableString *configurationString = [NSMutableString stringWithFormat:@"%@/amazon/upload", [SDUserSettings serviceURL]];
    
    NSMutableURLRequest *networkRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:configurationString]];
        
    NSString *boundary = [self.utility generateBoundaryString];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [networkRequest setValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                            [[MTDataModel sharedDatabaseStorage] getAccessToken], @"accessToken",
                            self.title, @"title",
                            self.description, @"description",
                            self.category, @"category",
                            nil];
    
    NSData *httpBody = [self.utility createBodyWithBoundary:boundary
                                                 parameters:params
                                                       path:self.path
                                                  videoData:self.videoData
                                                  fieldName:@"file"];
    
    networkRequest.HTTPBody = httpBody;
    networkRequest.HTTPMethod = @"POST";
    return networkRequest;
}

- (SDResult *)emptyResponse
{
    return [[MTUploadVideoResponse alloc] init];
}

- (SDMultipartRequestUtility *)utility {
    if (!_utility) {
        _utility = [[SDMultipartRequestUtility alloc] init];
    }
    
    return _utility;
}


@end
