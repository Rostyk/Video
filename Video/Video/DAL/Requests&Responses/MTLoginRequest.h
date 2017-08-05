//
//  MTLoginRequest.h
//  Automatize
//
//  Created by Rostyslav.Stepanyak on 3/15/17.
//  Copyright © 2017 Tilf AB. All rights reserved.
//

#import "SDRequest.h"

@interface MTLoginRequest : SDRequest

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;


@end
