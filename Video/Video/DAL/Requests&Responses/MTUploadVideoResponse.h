//
//  MTUploadSandTicketResponse.h
//  Automatize
//
//  Created by Rostyslav.Stepanyak on 3/17/17.
//  Copyright © 2017 Tilf AB. All rights reserved.
//

#import "SDResult.h"

@interface MTUploadVideoResponse : SDResult
@property (nonatomic) BOOL success;
- (void)parseResponseData:(NSData *)responseData;
@end
