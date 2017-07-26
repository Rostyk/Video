//
//  SServiceRequestHandler.m
//  

#import "SDServiceRequestHandler.h"
#import "SDResult.h"

#import "SDUserSettings.h"
#import "SDDispatcher.h"


// --- STATUS ----
#define MT_HTTP_SUCCESS 200
#define MT_HTTP_STATUS_OK 4
#define MT_HTTP_EXPIRED 401


#define LOG_NETWORK
#define IS_SUCCESSFUL_HTTP_STATUS(r)  (((r) / 100) == 2)


static NSTimeInterval   MLRequestTimeoutInterval        = 90;

static NSString * const SDNullJsonParam                 = @"null";
static NSString * const SDTrueJsonParam                 = @"true";
static NSString * const SDFalseJsonParam                = @"false";

//static const NSUInteger SDHTTPStatusCode409Conflict     = 409;


@interface SDServiceRequestHandler () <NSURLSessionTaskDelegate>
{
    // upload session is background
    NSURLSession *uploadSession_;
    // general session is general
    NSURLSession *requestSession_;
}

- (NSURLRequest *)serviceURLRequestWithRequest:(SDRequest *)request;
- (SDResult *)processServiceFeedbackWithRequest:(SDRequest *)request
                                       response:(NSHTTPURLResponse *)networkResponse
                                   responseData:(NSData *)responseData;

- (NSString *)URLStringByAppendingParams:(NSString *)params toURLString:(NSString *)URLString;

@end


@implementation SDServiceRequestHandler

@synthesize serviceURL = serviceURL_;
@synthesize securityToken;

#pragma mark - Memory management

+ (id)serviceRequestHandlerWithSecurityToken:(NSString *)securityToken
{
    return [[self alloc] initWithSecurityToken:securityToken];
}

- (id)initWithSecurityToken:(NSString *)token
{
    self = [super init];
    
    if (self)
    {
        self.securityToken = token;
        [self updateWithSecurityToken:token];
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfiguration.HTTPMaximumConnectionsPerHost = 63;
    
        requestSession_ = [NSURLSession sessionWithConfiguration:sessionConfiguration  delegate:self delegateQueue:nil];

        uploadSession_ = [NSURLSession sessionWithConfiguration:sessionConfiguration  delegate:self delegateQueue:nil];
    }
    
    return self;
}

- (void)dealloc
{
    self.securityToken = nil;
    self.serviceURL = nil;
}

#pragma mark - session delegte

//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
//didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
// completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
//{
//    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
//}
//
//-(void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
//{
//    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
//}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {

        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
}

#pragma mark - Common request processing method

- (void)logNetworkRequest:(NSURLRequest *)request
{
    NSMutableString *headerFields = [NSMutableString string];
    
    for (NSString *field in [request.allHTTPHeaderFields allKeys])
    {
        [headerFields appendFormat:@"    %@: %@\n", field, [request.allHTTPHeaderFields valueForKey:field]];
    }
    
    NSString *body = request.HTTPBody.length > 0 ? (request.HTTPBody.length > 2048 ? [NSString stringWithFormat:@"    <%lu bytes>", (unsigned long)request.HTTPBody.length]
                                                    : [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]) : @"    <empty>";
    
    NSLog(@"\n----- [NETWORK REQUEST] -----\n  URL: %@\n  METHOD: %@\n  HEADER FIELDS\n%@  BODY\n%@\n-----------------------------\n",
          request.URL,
          request.HTTPMethod,
          headerFields,
          body);
}

- (void)logNetworkResponse:(NSHTTPURLResponse *)response error:(NSError *)error data:(NSData *)data
{
    if (error == nil)
    {
        /*NSLog(@"\n----- [NETWORK RESPONSE] -----\n  URL: %@\n  STATUS CODE: %li\n HEADER FIELDS\n%@  BODY\n    %@\n------------------------------\n",
              response.URL,
              (long)response.statusCode,
              response.allHeaderFields,
              data.length > 0 ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : @"<empty>");*/
    }
    else
    {
        NSLog(@"\n----- [NETWORK RESPONSE] -----\n  ERROR: %@\n", [error localizedDescription]);
    }
}

#pragma mark - Common request processing method

- (SDResult *)processRequest:(SDRequest *)request
{
    SDResult *result = nil;
    
    if ([SDInternetConnection networkStatus] != NotReachable)
    {
            NSURLRequest *networkRequest = nil;
            
            networkRequest = [self serviceURLRequestWithRequest:request];
            
#ifdef LOG_NETWORK
            [self logNetworkRequest:networkRequest];
#endif // LOG_NETWORK
            
            if (networkRequest != nil)
            {
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                __block NSData *responseData = nil;
                
                NSURLSessionDataTask *task = [requestSession_ dataTaskWithRequest:networkRequest
                                                                completionHandler:^(NSData *data,
                                                                                    NSURLResponse *response,
                                                                                    NSError *error) {
                                                                    responseData = data;
                                                                    dispatch_semaphore_signal(semaphore);
                                                                }];
                
                if (request.cancelBlock == nil)
                {
                    request.cancelBlock = ^
                    {
                        [task cancel];
                        dispatch_semaphore_signal(semaphore);
                    };
                }
                
                [task resume];
                
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                
//                double timePassed = [requestStart timeIntervalSinceNow] * -1000.0;
//                
//                if (timePassed > 500)
//                {
//                    // request took more than 0.5sec to complete
//                    [[GAI sharedInstance].defaultTracker send:[[GAIDictionaryBuilder createTimingWithCategory:request.description
//                                                                                                     interval:[NSNumber numberWithFloat:timePassed]
//                                                                                                         name:[NSString stringWithFormat:@"requestSuccess:%@",[result isSuccess] ? @"YES" : @"NO"]
//                                                                                                        label:[NSString stringWithFormat:@"responseTime:%f", timePassed]] build]];
//                }
                
                if ([request isCanceled])
                {
                    NSLog(@"[SERVICE REQUEST]: cancelled request %@", request);
                }
                else
                {
                    result = task.error == nil ? [self processServiceFeedbackWithRequest:request response:(NSHTTPURLResponse *)task.response responseData:responseData]
                    : [SDResult errorWithCode:task.error.code message:[task.error localizedDescription]];
                }
                
#ifdef LOG_NETWORK
                [self logNetworkResponse:(NSHTTPURLResponse *)task.response error:task.error data:responseData];
#endif // LOG_NETWORK
            }
            else if (result == nil)
            {
                // invalid client state or method is not implemented
                // TODO: revise?
                result = [SDResult errorWithCode:0];
            }
    }
    else
    {
        result = [SDResult errorWithCode:0 message:@"No internet connection"];
    }
    
    return result;
}

#pragma mark - Public methods

- (void)updateWithSecurityToken:(NSString *)token
{
    serviceAuthString_ = securityToken.length > 0 ? [NSString stringWithFormat:@"access_token=\"%@\"", token] : nil;
}

#pragma mark - Helper methods

- (NSURLRequest *)serviceURLRequestWithRequest:(SDRequest *)request
{
//    BOOL acceptJSON = YES;
    
    NSMutableURLRequest *networkRequest = [request serviceURLRequest];
    
    if (networkRequest.URL != nil)
    {
        if ([networkRequest valueForHTTPHeaderField:@"Accept"] == nil)
        {
            [networkRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        }
        
        [networkRequest setValue:securityToken forHTTPHeaderField:@"Access-Token"];
        
        if ([networkRequest.HTTPBody length] > 0)
        {
            [networkRequest setValue:@([networkRequest.HTTPBody length]).stringValue forHTTPHeaderField:@"Content-Length"];
        }
        
        if ([networkRequest valueForHTTPHeaderField:@"Content-Type"] == nil)
        {
            
            [networkRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        }
        
        if (networkRequest.HTTPMethod == nil)
        {
            networkRequest.HTTPMethod = @"GET";
        }
        
        networkRequest.timeoutInterval = MLRequestTimeoutInterval;
    }
    else
    {
        networkRequest = nil;
    }
    
    return networkRequest;
}

- (SDResult *)processServiceFeedbackWithRequest:(SDRequest *)request
                                       response:(NSHTTPURLResponse *)networkResponse
                                          responseData:(NSData *)responseData
{
    SDResult *result = nil;
    
    NSString *str = [[NSString alloc] initWithData:responseData encoding: NSUTF8StringEncoding];
    NSLog(@"Response: %@", str);
    if (IS_SUCCESSFUL_HTTP_STATUS(networkResponse.statusCode))
    {
        // try to extract error message
        NSError *error = nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
        
        if (!error && ([jsonDict[@"status"] integerValue] != MT_HTTP_SUCCESS && [jsonDict[@"status"] integerValue] != MT_HTTP_STATUS_OK))
        {
            NSString *message = jsonDict[@"message"];
            int statusCode = (int)[jsonDict[@"status"] integerValue];
            result = [SDResult errorWithCode:statusCode message:message.length > 0 ? message : @"An Error occured"];
        }
        else
        {
            result = [request emptyResponse];
            [result parseResponseData:responseData];
        }
    }
    else
    {
        result = [SDResult errorWithCode:401];
        
        // try to extract error message
        NSError *error = nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&error];
        
        if (!error)
        {
            result = [SDResult errorWithCode:401 message:[jsonDict[@"message"] isKindOfClass:NSString.class] ? jsonDict[@"message"] : nil];
        }
    }

    if ([SDInternetConnection networkStatus] == NotReachable)
    {
        result = [SDResult errorWithCode:0];
    }

    return result;
}

- (NSString *)URLStringByAppendingParams:(NSString *)params toURLString:(NSString *)URLString
{
    if (URLString.length == 0)
    {
        return nil;
    }
    else if (params.length == 0)
    {
        return URLString;
    }
    else
    {
        return [URLString rangeOfString:@"?"].location == NSNotFound ? [NSString stringWithFormat:@"%@?%@", URLString, params]
            : [NSString stringWithFormat:@"%@&%@", URLString, params];
    }
}

@end
