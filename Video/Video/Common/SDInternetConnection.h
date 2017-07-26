//
//  SDInternetConnection.h
//  slimdoggy
//
//  Created by Stepan Koposov on 6/27/13.
//
//

#import <Foundation/Foundation.h>

#import "Reachability.h"


@interface SDInternetConnection : NSObject

+ (void)startInternetReachability;
+ (void)stopInternerReachability;

+ (NetworkStatus)networkStatus;

@end
