//
//  MLRequest.m

#import "SDRequest.h"
#import "SDDispatcher.h"


const NSUInteger    SDInitialHandlerStackSize = 4;

const NSString *SDNullJsonParam                 = @"null";
const NSString *SDTrueJsonParam                 = @"true";
const NSString *SDFalseJsonParam                = @"false";


@interface SDRequest ()

@end

@implementation SDRequest

@synthesize owner = owner_;
@synthesize delegate;
@synthesize canceled = canceled_;
@synthesize cancelBlock = cancelBlock_;
@synthesize completionBlock = completionBlock_;

+ (id)requestWithOwner:(id)owner
{
    SDRequest *request = [[self alloc] init];
    
    request.owner = owner;
    
    return request;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        requestHandlerStack_ = [NSMutableArray arrayWithCapacity:SDInitialHandlerStackSize];
    }
    
    return self;
}

- (NSMutableURLRequest *)serviceURLRequest;
{
    return nil;
}

- (SDResult *)emptyResponse
{
    return nil;
}

- (void)pushRequestDelegate:(id<SDRequestDelegate>)theDelegate
{
    if (theDelegate != nil)
    {
        [requestHandlerStack_ addObject:theDelegate];
    }
}

- (id<SDRequestDelegate>)popRequestDelegate
{
    if (requestHandlerStack_.count == 0)
    {
        return nil;
    }
    
    id<SDRequestDelegate> theDelegate = [requestHandlerStack_ lastObject];
    [requestHandlerStack_ removeLastObject];
    
    return theDelegate;
}

- (void)cancel
{
    if (canceled_)
    {
        return;
    }
    
    canceled_ = YES;
    
    if (cancelBlock_ != nil)
    {
        cancelBlock_();
    }
}

- (BOOL)loopProcessing
{
    return NO;
}

- (BOOL)requiresInternalHandling
{
    return NO;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"Request { typeId: %lu; }", (unsigned long)self.typeId];
}

- (void)run {
    [[SDDispatcher sharedInstance] processRequest:self];
}

@end
