//
//  SDRequestHandler.m
//  

#import "SDRequestHandler.h"


@interface SDRequestHandler ()

- (void)reportRequest:(SDRequest *)request 
didFinishWithResponse:(SDResult *)result 
             delegate:(id<SDRequestDelegate>)delegate;

@end

@implementation SDRequestHandler

@synthesize nextHandler = nextHandler_;

- (SDResult *)processRequest:(SDRequest *)request
{
    return nil;
}

- (void)processRequest:(SDRequest *)request withDelegate:(id<SDRequestDelegate>)delegate
{
    SDResult *result = [self processRequest:request];
    
    if (result == nil && nextHandler_ != nil)
    {
        [request pushRequestDelegate:delegate];
        [nextHandler_ processRequest:request withDelegate:self];
    }
    else
    {
        [self reportRequest:request didFinishWithResponse:result delegate:delegate];
    }
}

- (void)request:(SDRequest *)request didFinishWithResult:(SDResult *)result
{
    [self reportRequest:request didFinishWithResponse:result delegate:[request popRequestDelegate]];
}

- (void)reportRequest:(SDRequest *)request 
didFinishWithResponse:(SDResult *)result 
             delegate:(id<SDRequestDelegate>)theDelegate
{
    if ([request isCanceled])
    {
        NSLog(@"[%@]: dropping request %@", self, request);
        return;
    }
    
    if (theDelegate == nil)
    {
        if (request.completionBlock != nil)
        {
            request.completionBlock(request, result);
        }
        else
        {
            [request.delegate request:request didFinishWithResult:result];
        }
    }
    else
    {
        [theDelegate request:request didFinishWithResult:result];
    }
}

- (void)cancellAllRequestsWithOwner:(id)owner
{
}

- (void)cancellAllRequests
{
}

@end
