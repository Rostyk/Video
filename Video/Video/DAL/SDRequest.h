//
//  MLRequest.h

#import <Foundation/Foundation.h>

#import "SDDispatcher.h"
#import "SDAuth.h"
#import "SDUserSettings.h"

@class SDRequest;
@class SDResult;

@protocol SDRequestDelegate <NSObject>

@required
- (void)request:(SDRequest *)request didFinishWithResult:(SDResult *)result;

@end

typedef void (^SDRequestGeneralProgressBlock)(float progress);
typedef void (^SDRequestCompletionBlock)(SDRequest *request, SDResult *response);
typedef void (^SDRequestCancelBlock)();
typedef void (^SDRequestProgressBlock)(SDRequest *request, float progress); // progress range is [0, 1]

@interface SDRequest : NSObject
{
@private
    NSMutableArray *requestHandlerStack_;
    BOOL canceled_;
    SDRequestCancelBlock cancelBlock_;
    SDRequestCompletionBlock completionBlock_;
}

@property (nonatomic, strong) id owner;
@property (nonatomic, assign) NSUInteger typeId;
@property (nonatomic, readonly, getter = isCanceled) BOOL canceled;
@property (nonatomic, copy) SDRequestCancelBlock cancelBlock;
@property (nonatomic, assign) id<SDRequestDelegate> delegate;
@property (nonatomic, copy) SDRequestCompletionBlock completionBlock;

+ (id)requestWithOwner:(id)owner;

- (NSMutableURLRequest *)serviceURLRequest;
- (SDResult *)emptyResponse;

- (void)pushRequestDelegate:(id<SDRequestDelegate>)delegate;
- (id<SDRequestDelegate>)popRequestDelegate;

- (void)cancel;
- (void)run;

- (BOOL)loopProcessing;
- (BOOL)requiresInternalHandling;

@end
