//
//  SDInternetConnection.m
//  slimdoggy
//
//  Created by Stepan Koposov on 6/27/13.
//
//

#import "SDInternetConnection.h"
#import "Strings.h"


static Reachability *SDReachability = nil;
static BOOL SDReachabilityOn;

static inline Reachability *defaultReachability()
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        SDReachability = [Reachability reachabilityForInternetConnection];
    });

    return SDReachability;
}

@interface SDInternetConnection ()

+ (void)checkNetworkStatus;
+ (void)showBanner;
+ (void)cancel;

@end

@implementation SDInternetConnection

#pragma mark - Public methods

+ (void)startInternetReachability
{
    if (!SDReachabilityOn)
    {
        SDReachabilityOn = YES;
        [defaultReachability() startNotifier];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkNetworkStatus)
                                                 name:kReachabilityChangedNotification
                                               object:nil];

    [self checkNetworkStatus];
}

+ (void)stopInternerReachability
{
    SDReachabilityOn = NO;

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kReachabilityChangedNotification
                                                  object:nil];
}

+ (NetworkStatus)networkStatus
{
    return [defaultReachability() currentReachabilityStatus];
}

#pragma mark - Private methods

+ (void)checkNetworkStatus
{
    // called after network status changes
    NetworkStatus internetStatus = [defaultReachability() currentReachabilityStatus];

    switch (internetStatus)
    {
        case NotReachable:
        {
            [self cancel];
            [self performSelector:@selector(showBanner) withObject:nil afterDelay:0.1];
            
            break;
        }

        case ReachableViaWiFi:
        case ReachableViaWWAN:
        {
            [self cancel];
            
            break;
        }
            
        default:
            break;
    }
}

+ (void)showBanner
{

}

+ (void)cancel
{
    [SDInternetConnection cancelPreviousPerformRequestsWithTarget:self selector:@selector(showBanner) object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
