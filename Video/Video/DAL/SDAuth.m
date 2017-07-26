//
//  SDAuth.m
//  

#import "SDAuth.h"
#import "NSString+SDAdditions.h"

#import "SDInternetConnection.h"
#import "SDResult.h"

#import "SDUserSettings.h"
#import "SDKeyStorage.h"

const NSTimeInterval        MLAuthTimeoutInteraval = 60.0f;

const float                 MLAuthSimulationMinDelay = 0.0;
const float                 MLAuthSimulationMaxDelay = 1.0;
const float                 MLAuthSimulationFailProbability = 0.0;

static NSString * const SDNullJsonParam                 = @"null";

#pragma mark - Helper functions


const NSString *SDResponseData = @"data";
const NSString *SDAccessToken  = @"access_token";
const NSString *SDUserId       = @"id";

#pragma mark - MLAuth

@interface SDAuth ()
{
    NSString *serviceURL_;
    NSString *securityToken_;
    NSDate *tokenValidTill_;
    NSString *userName_;
    NSNumber *userId_;
    NSString *passwordHash_;
    NSURLSession *session_;
    NSURLSessionDataTask *authRequest_;
}
@property (nonatomic, strong) NSString *passwordHash;
@end


@implementation SDAuth

@synthesize serviceURL = serviceURL_;
@synthesize delegate = delegate_;
@synthesize securityToken = securityToken_;
@synthesize tokenValidTill = tokenValidTill_;
@synthesize userName = userName_;
@synthesize userId = userId_;
@synthesize passwordHash = passwordHash_;

#pragma mark - Memory management

- (id)initWithServiceURL:(NSString *)serviceURL delegate:(id<SDAuthDelegate>)delegate
{
    self = [super init];
    
    if (self)
    {
        self.serviceURL = serviceURL;
        self.delegate = delegate;
        
        // restore the info
        if ([SDUserSettings accessToken].length > 0 && [SDUserSettings userId].integerValue != 0 && [SDKeyStorage passwordWithUsername:[SDUserSettings userName]].length > 0)
        {
            userName_ = [SDUserSettings userName];
            passwordHash_ = [SDKeyStorage passwordWithUsername:userName_];
            securityToken_ = [SDUserSettings accessToken];
            userId_ = [SDUserSettings userId];
        }
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        session_ = [NSURLSession sessionWithConfiguration:sessionConfiguration];
        
        serviceURL_ = [SDUserSettings serviceURL];
    }
    
    return self;
}

- (id)initWithServiceURL:(NSString *)serviceURL
{
    return [self initWithServiceURL:serviceURL delegate:nil];
}

- (void)dealloc
{
    [authRequest_ cancel];
}

#pragma mark - this shouldn't be here

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

#pragma mark - Properties

- (void)authenticateWithUserName:(NSString *)userName
                    passwordHash:(NSString *)passwordHash
{
    if ([self isAuthenticating])
    {
        return;
    }
    else
    {
        if ([SDInternetConnection networkStatus] != NotReachable)
        {
            if (serviceURL_ != nil)
            {
                userName_ = userName;
                self.passwordHash = passwordHash_;
                
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@account/login", serviceURL_]]];
                
                request.HTTPMethod = @"POST";
                request.timeoutInterval = MLAuthTimeoutInteraval;
                
                // Setting Body
                NSString *postBody = [NSString stringWithFormat:@"email=%@&password=%@", [userName URLEncodedString], passwordHash];
                
                [request setHTTPBody:[postBody dataUsingEncoding:NSUTF8StringEncoding]];
                
                [self logNetworkRequest:request];
                
                authRequest_ = [session_ dataTaskWithRequest:request
                                                            completionHandler:^(NSData *data,
                                                                                NSURLResponse *response,
                                                                                NSError *error) {
                                                                if (!error)
                                                                {
                                                                    [self logNetworkResponse:(NSHTTPURLResponse *)response error:error data:data];
                                                                    
                                                                    NSError *error = nil;
                                                                    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                             options:NSJSONReadingMutableContainers
                                                                                                                               error:&error];
                                                                    
                                                                    if (!error)
                                                                    {
                                                                        NSDictionary *responseDictionary = [jsonDict objectForKey:SDResponseData];
                                                                        
                                                                        if ([responseDictionary isKindOfClass:NSDictionary.class] && [responseDictionary objectForKey:SDAccessToken] != nil)
                                                                        {
                                                                            NSLog(@"[AUTH]: first stage succeeded");
                                                                            
                                                                            securityToken_ = [responseDictionary objectForKey:SDAccessToken];
                                                                            [SDUserSettings setAccessToken:securityToken_];
//                                                                            userId_ = [responseDictionary objectForKey:SDUserId];
//                                                                            [SDUserSettings setUserId:userId_];
                                                                            
                                                                            [delegate_ didSucceedAuthentication:self keepAlive:NO];
                                                                        }
                                                                        else
                                                                        {
                                                                            NSLog(@"[AUTH]: login failed (invalid token data)");
                                                                            [delegate_ authentication:self didFailWithError:[SDResult errorWithCode:((NSHTTPURLResponse *)response).statusCode]];
                                                                            
                                                                            [self drop];
                                                                        }
                                                                    }
                                                                    else
                                                                    {
                                                                        [delegate_ authentication:self
                                                                                 didFailWithError:[SDResult errorWithCode:0
                                                                                                                  message:[error localizedDescription]]];
                                                                        
                                                                        [self drop];
                                                                    }
                                                                }
                                                            }];
                
                [authRequest_ resume];
            }
            else
            {
                
            }
        }
        else
        {
            NSLog(@"[AUTH]: No Internet connection!");
            [delegate_ authentication:self
                     didFailWithError:[SDResult errorWithCode:0]];
        }
    }
}

- (void)drop
{
    @synchronized (self)
    {
        [authRequest_ cancel];
        
        authRequest_ = nil;
        securityToken_ = nil;
        userName_ = nil;
        userId_ = nil;
        passwordHash_ = nil;
    }
}

- (void)logout
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@auth?token=%@", serviceURL_, securityToken_]]];
    
    request.HTTPMethod = @"DELETE";
    request.timeoutInterval = MLAuthTimeoutInteraval;
    
    [self logNetworkRequest:request];
    
    authRequest_ = [session_ dataTaskWithRequest:request
                               completionHandler:^(NSData *data,
                                                   NSURLResponse *response,
                                                   NSError *error) {
                                   if (!error)
                                   {
                                       [self logNetworkResponse:(NSHTTPURLResponse *)response error:error data:data];
                                       
                                       NSError *error = nil;
                                       NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data
                                                                                                options:NSJSONReadingMutableContainers
                                                                                                  error:&error];
                                       
                                       if (!error)
                                       {
                                           NSLog(@"Logout error: %@", jsonDict.description);
                                       }
                                   }
                               }];
    
    [authRequest_ resume];
}

- (void)refreshToken
{
    [self authenticateWithUserName:userName_ passwordHash:passwordHash_];
}

- (BOOL)isAuthenticating
{
    return authRequest_ != nil;
}

- (BOOL)isAuthenticated
{
    return userName_ != nil;
}

/// MD5
+ (NSString *)hashWithPassword:(NSString *)password
{
    // Create pointer to the string as UTF8
    const char *ptr = [password UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

@end
