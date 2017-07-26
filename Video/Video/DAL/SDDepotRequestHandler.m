//
//  SDDepotRequestHandler.m
//  

#import "SDDepotRequestHandler.h"


//#define LOG_DEPOT_OPERATIONS

@implementation SDDepotRequestHandler

- (id)init
{
    self = [super init];
    
    if (self)
    {
        currentRequests_ = [[NSMutableSet alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [self cancellAllRequests];
    
    self.nextHandler = nil;
}

- (void)processRequest:(SDRequest *)request withDelegate:(id<SDRequestDelegate>)delegate
{
#ifdef LOG_DEPOT_OPERATIONS
    NSLog(@"[REQUEST DEPOT]: adding request %@", request);
#endif // LOG_DEPOT_OPERATIONS
    
    @synchronized (self)
    {
        [currentRequests_ addObject:request];
    }
    
    if ([NSThread isMainThread])
    {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                       ^(void)
                       {
                           [super processRequest:request withDelegate:self];
                       });
    }
    else
    {
        [super processRequest:request withDelegate:self];
    }
}

- (void)cancellAllRequestsWithOwner:(id)owner
{
#ifdef LOG_DEPOT_OPERATIONS
    NSLog(@"[REQUEST DEPOT]: cancelAllRequests owned by %@", owner);
#endif // LOG_DEPOT_OPERATIONS
    
    for (SDRequest *request in [currentRequests_ allObjects])
    {
        if (request.owner == owner)
        {
#ifdef LOG_DEPOT_OPERATIONS
            NSLog(@"[REQUEST DEPOT]: cancelling request %@", request);
#endif // LOG_DEPOT_OPERATIONS
            [request cancel];
        }
    }
}

- (void)cancellAllRequests
{
#ifdef LOG_DEPOT_OPERATIONS
    NSLog(@"[REQUEST DEPOT]: cancelAllRequests called (%i requests are in progress)", currentRequests_.count);
#endif // LOG_DEPOT_OPERATIONS
    
    for (SDRequest *request in currentRequests_)
    {
#ifdef LOG_DEPOT_OPERATIONS
        NSLog(@"[REQUEST DEPOT]: cancelling request %@", request);
#endif // LOG_DEPOT_OPERATIONS
        [request cancel];
    }
}

- (void)request:(SDRequest *)request didFinishWithResult:(SDResult *)result
{
    dispatch_async(dispatch_get_main_queue(), ^(void){
#ifdef LOG_DEPOT_OPERATIONS
        NSLog(@"[REQUEST DEPOT]: removing request %@", request);
#endif // LOG_DEPOT_OPERATIONS
        
        @synchronized (self)
        {
            [currentRequests_ removeObject:request];
        
        
        if (![request isCanceled])
        {
            [super request:request didFinishWithResult:result];
        }
#ifdef LOG_DEPOT_OPERATIONS
        else
        {
            NSLog(@"[REQUEST DEPOT]: request %@ has been canceled!", request);
        }
#endif // LOG_DEPOT_OPERATIONS
        }
    });
    
//    // switch back to the main thread is needed
//    if (![NSThread isMainThread])
//    {
//        dispatch_async(dispatch_get_main_queue(), ^(void)
//                       {
////                           [self request:request didFinishWithResult:result];
//
//#ifdef LOG_DEPOT_OPERATIONS
//                           NSLog(@"[REQUEST DEPOT]: removing request %@", request);
//#endif // LOG_DEPOT_OPERATIONS
//                           
//                           @synchronized (self)
//                           {
//                               [currentRequests_ removeObject:request];
//                           }
//                           
//                           if (![request isCanceled])
//                           {
//                               [super request:request didFinishWithResult:result];
//                           }
//#ifdef LOG_DEPOT_OPERATIONS
//                           else
//                           {
//                               NSLog(@"[REQUEST DEPOT]: request %@ has been canceled!", request);
//                           }
//#endif // LOG_DEPOT_OPERATIONS
//                       });
//    }
//    else
//    {
//#ifdef LOG_DEPOT_OPERATIONS
//        NSLog(@"[REQUEST DEPOT]: removing request %@", request);
//#endif // LOG_DEPOT_OPERATIONS
//        
//        @synchronized (self)
//        {
//            [currentRequests_ removeObject:request];
//        }
//        
//        if (![request isCanceled])
//        {
//            [super request:request didFinishWithResult:result];
//        }
//#ifdef LOG_DEPOT_OPERATIONS
//        else
//        {
//            NSLog(@"[REQUEST DEPOT]: request %@ has been canceled!", request);
//        }
//#endif // LOG_DEPOT_OPERATIONS
//    }
}

@end
