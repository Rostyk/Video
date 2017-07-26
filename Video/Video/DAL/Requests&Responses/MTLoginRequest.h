//
//  MTLoginRequest.h
//  Automatize
//
//  Created by Rostyslav.Stepanyak on 3/15/17.
//  Copyright © 2017 Tilf AB. All rights reserved.
//

#import "SDRequest.h"

@interface MTLoginRequest : SDRequest

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic, strong) NSString *deviceType;
@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *lon;

@end
