//
//  NSObject+PNCast.m
//  Orange Harp
//
//  Created by Steven on 28/07/14.
//  Copyright (c) 2014 Orange Harp. All rights reserved.
//

#import "NSObject+PNCast.h"

@implementation NSObject (PNCast)
+ (instancetype)cast:(id)object {
    return [object isKindOfClass:self] ? object : nil;
}
@end
