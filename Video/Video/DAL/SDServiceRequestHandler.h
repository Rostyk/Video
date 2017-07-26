//
//  SDServiceRequestHandler.h
//  

#import <Foundation/Foundation.h>
#import "SDRequestHandler.h"
#import "SDInternetConnection.h"


@interface SDServiceRequestHandler : SDRequestHandler
{
@private
    NSString *serviceURL_;
    NSString *serviceAuthString_;
    Reachability *hostReach_;
}

@property (nonatomic, copy) NSString *serviceURL;
@property (nonatomic, copy) NSString *securityToken;

+ (id)serviceRequestHandlerWithSecurityToken:(NSString *)securityToken;

- (id)initWithSecurityToken:(NSString *)securityToken;

- (void)updateWithSecurityToken:(NSString *)securityToken;

- (SDResult *)processRequest:(SDRequest *)request;

@end
