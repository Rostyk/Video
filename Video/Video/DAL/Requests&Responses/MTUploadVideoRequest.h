//
//  MTUploadSandTicketRequest.h
//  Automatize
//
//  Created by Rostyslav.Stepanyak on 3/17/17.
//  Copyright © 2017 Tilf AB. All rights reserved.
//

#import "SDRequest.h"

@interface MTUploadVideoRequest : SDRequest
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *description;

@property (nonatomic, strong) NSData *videoData;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *category;
@end
