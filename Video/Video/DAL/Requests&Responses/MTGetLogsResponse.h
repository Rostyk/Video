//
//  MTGetLogsResponse.h
//  Automatize
//
//  Created by Rostyslav.Stepanyak on 3/17/17.
//  Copyright © 2017 Tilf AB. All rights reserved.
//

#import "SDResult.h"

@interface MTGetLogsResponse : SDResult
@property (nonatomic, strong) NSArray *logs;
@end
