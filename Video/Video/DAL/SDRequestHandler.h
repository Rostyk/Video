//
//  SDRequestHandler.h
//  

#import <Foundation/Foundation.h>
#import "SDRequest.h"


@class SDResult;

@interface SDRequestHandler : NSObject <SDRequestDelegate>
{
@private
    SDRequestHandler *nextHandler_;
}

@property (nonatomic, retain) SDRequestHandler *nextHandler;

- (SDResult *)processRequest:(SDRequest *)request;
- (void)processRequest:(SDRequest *)request withDelegate:(id<SDRequestDelegate>)delegate;

- (void)cancellAllRequestsWithOwner:(id)owner;
- (void)cancellAllRequests;

- (void)request:(SDRequest *)request didFinishWithResult:(SDResult *)result;

@end
