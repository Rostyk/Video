//
//  MTLoginResponse.m
//  Automatize
//
//  Created by Rostyslav.Stepanyak on 3/15/17.
//  Copyright © 2017 Tilf AB. All rights reserved.
//

#import "MTLoginResponse.h"

@implementation MTLoginResponse

- (void)parseResponseData:(NSData *)responseData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.accessToken = [[MTDataModel sharedDatabaseStorage] parseLogin:responseData];
    });
}

@end
