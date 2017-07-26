//
//  MTGetLogsResponse.m
//  Automatize
//
//  Created by Rostyslav.Stepanyak on 3/17/17.
//  Copyright © 2017 Tilf AB. All rights reserved.
//

#import "MTGetLogsResponse.h"

@implementation MTGetLogsResponse

- (void)parseResponseData:(NSData *)responseData {
    dispatch_async(dispatch_get_main_queue(), ^{
        //self.logs = [[MTDataModel sharedDatabaseStorage] parseLogs:responseData];
    });
}

@end
