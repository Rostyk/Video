//
//  MTLoginResponse.h
//  Automatize
//
//  Created by Rostyslav.Stepanyak on 3/15/17.
//  Copyright © 2017 Tilf AB. All rights reserved.
//

#import "SDResult.h"

@interface MTLoginResponse : SDResult
@property (nonatomic, strong) NSString *accessToken;
@end
