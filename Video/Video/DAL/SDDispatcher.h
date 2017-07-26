//
//  SDDispatcher.h
//  

#import <Foundation/Foundation.h>
#import "SDResult.h"
#import "SDRequest.h"
#import "SDAuth.h"


@protocol SDLoginDelegate <NSObject>

@required
- (void)loginDidSucceedKeepAlive:(BOOL)keepAlive;
- (void)loginDidFailWithError:(SDResult *)error;

@end


@class SDRequestHandler;
@class MLCacheRequestHandler;
@class MLClientStateRequestHandler;
@class SDServiceRequestHandler;
@class MLClientState;
@class SDSettings;
@class SDRequest;

@interface SDDispatcher : NSObject <SDAuthDelegate>

@property (nonatomic, readonly, getter = isLoggedIn) BOOL loggedIn;
@property (nonatomic, readonly) MLClientState *currentClientState;
@property (nonatomic, readonly) NSNumber *currentUserId;

// TODO: remove in 1.3
@property (nonatomic, strong) SDAuth *auth;

+ (SDDispatcher *)sharedInstance;

- (void)loginWithUserName:(NSString *)userName
             passwordHash:(NSString *)passwordHash
                 delegate:(id<SDLoginDelegate>)delegate;
- (void)logout;

- (void)setupSessionWithUserName:(NSString *)userName;

- (void)processRequest:(SDRequest *)request;
- (void)cancelAllRequestsWithOwner:(id)owner;

@end
