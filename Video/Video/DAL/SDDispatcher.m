//
//  SDDispatcher.m
// 

#import "SDDispatcher.h"
#import "SDUserSettings.h"
#import "SDKeyStorage.h"

#import "SDRequestHandler.h"
#import "SDServiceRequestHandler.h"
#import "SDDepotRequestHandler.h"

//#import "MTDataModel.h"
//#import "SDSettings.h"
#import "SDUserSettings.h"


NSTimeInterval      SDTokenRefreshRetryInterval     = 60 * 30;
NSTimeInterval      SDTokenRefreshShiftInterval     = 30;

static SDDispatcher *dispatcherSharedInstance = nil;

#pragma mark - MLDispatcher private category declaration

@interface SDDispatcher ()

@property (nonatomic, assign) id<SDLoginDelegate> loginDelegate;

@property (nonatomic, strong) SDServiceRequestHandler *serviceRequestHandler;
@property (nonatomic, strong) SDRequestHandler *headRequestHandler;
//@property (nonatomic, strong) SDAuth *auth;
@property (nonatomic, assign) BOOL refreshingAccessToken;

@property (nonatomic, assign) BOOL settingReloaded;

- (void)setupSessionWithUserName:(NSString *)userID;
- (void)releaseSession;

- (void)refreshAccessToken;

@end


#pragma mark - SDDispatcher implementation

@implementation SDDispatcher

@synthesize loggedIn;
@synthesize loginDelegate;

@synthesize serviceRequestHandler;
@synthesize headRequestHandler;
@synthesize auth;
@synthesize refreshingAccessToken;

#pragma mark - Memory management

- (id)init
{
    self = [super init];
    
    if (self != nil)
    {
        self.auth = [[SDAuth alloc] initWithServiceURL:[SDUserSettings serviceURL] delegate:self];
    }
    
    return self;
}

- (void)dealloc
{
    [self logout];
}

#pragma mark - Singleton

+ (SDDispatcher *)sharedInstance
{
    static SDDispatcher *sharedInstance = nil;
    static dispatch_once_t pred;
    
    if (!sharedInstance)
    {
        dispatch_once(&pred, ^{
            sharedInstance = [[SDDispatcher alloc] init];
            [sharedInstance setupSessionWithUserName:nil];
        });
    }
    
    return sharedInstance;
}

// TODO: add "singleton-proper" retain/release/etc methods
    
#pragma mark - Login/logout

- (void)loginWithUserName:(NSString *)userName
             passwordHash:(NSString *)passwordHash
                 delegate:(id<SDLoginDelegate>)delegate
{
    if (self.auth.authenticated || self.auth.authenticationInProgress)
    {
        [self.auth drop];
//        return;
    }
    
    self.loginDelegate = delegate;
    
    [self.auth authenticateWithUserName:userName passwordHash:passwordHash];
}

- (void)logout
{
    [self.headRequestHandler cancellAllRequests];
    
//    [self.auth logout];
    
    NSString *userName = [SDUserSettings userName];
    
    if (userName != nil)
    {
        [SDKeyStorage deletePasswordWithUsername:userName];
        [SDUserSettings setUserName:nil];
        [SDUserSettings setAccessToken:nil];
        [SDUserSettings setUserId:nil];
    }
    
//    // TODO: properly interrupt authentication in progress, check if currently authenticated
//    [self releaseSession];
}

- (BOOL)isLoggedIn
{
    return self.headRequestHandler != nil; // TODO: update once session information is available
}

- (void)reloadSettings
{
//    cacheRequestHandler_.on = [MLUserSettings cacheEnabled];
}

#pragma mark - Request processing

- (void)processRequest:(SDRequest *)request
{
    [self.headRequestHandler processRequest:request withDelegate:nil];
}

- (void)cancelAllRequestsWithOwner:(id)owner
{
    [self.headRequestHandler cancellAllRequestsWithOwner:owner];
}

#pragma mark - Session handling

- (void)setupSessionWithUserName:(NSString *)userName 
{
    @synchronized (self)
    {
        self.headRequestHandler = [[SDDepotRequestHandler alloc] init];
        SDRequestHandler *tail = self.headRequestHandler;
//        
//        clientStateRequestHandler_ = [[MLClientStateRequestHandler alloc] initWithUserName:userName];
//        tail.nextHandler = clientStateRequestHandler_;
//        tail = tail.nextHandler;
//       
//        cacheRequestHandler_ = [[MLCacheRequestHandler alloc] initWithUserName:userName];
//        tail.nextHandler = cacheRequestHandler_;
//        tail = tail.nextHandler;
//        
        self.serviceRequestHandler = [[SDServiceRequestHandler alloc] initWithSecurityToken:self.auth.securityToken];
        self.serviceRequestHandler.serviceURL = [SDUserSettings serviceURL];
        tail.nextHandler = self.serviceRequestHandler;
//
//        [clientStateRequestHandler_ refreshState];
        
        [self reloadSettings];
    }
}

- (void)releaseSession
{
    @synchronized (self)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshAccessToken) object:nil];
        
        [self.auth drop];
//        self.auth = nil;
        self.serviceRequestHandler = nil;
        self.headRequestHandler = nil;
    }
}

- (void)refreshAccessToken
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshAccessToken) object:nil];

    self.refreshingAccessToken = YES;
    
    [self.auth refreshToken];
}

#pragma mark - Auth delegate

- (void)didSucceedAuthentication:(SDAuth *)authentication keepAlive:(BOOL)keepAlive
{
    if (!self.refreshingAccessToken)
    {
        [self setupSessionWithUserName:authentication.userName];
        [self.loginDelegate loginDidSucceedKeepAlive:keepAlive];
    }
    else
    {
        [self.serviceRequestHandler updateWithSecurityToken:self.auth.securityToken];
    }
    
    self.refreshingAccessToken = NO;
    
    NSTimeInterval nextTokenRefreshDelay = [self.auth.tokenValidTill timeIntervalSinceNow] - SDTokenRefreshShiftInterval;
    if (nextTokenRefreshDelay < 0)
    {
        nextTokenRefreshDelay = SDTokenRefreshRetryInterval;
    }
    
    [self performSelector:@selector(refreshAccessToken) withObject:nil afterDelay:nextTokenRefreshDelay];
}

- (void)didCancelAuthentication:(SDAuth *)authentication
{
    [loginDelegate loginDidFailWithError:nil]; // TODO: revise

    if (self.refreshingAccessToken)
    {
        self.refreshingAccessToken = NO;
        [self performSelector:@selector(refreshAccessToken) withObject:nil afterDelay:SDTokenRefreshRetryInterval];
    }
}

- (void)authentication:(SDAuth *)authentication didFailWithError:(SDResult *)error
{
    // TODO: consider showing some message on fail while refreshing token
    [loginDelegate loginDidFailWithError:error];
    
    if (self.refreshingAccessToken)
    {
        self.refreshingAccessToken = NO;
        [self performSelector:@selector(refreshAccessToken) withObject:nil afterDelay:SDTokenRefreshRetryInterval];
    }
}

#pragma mark - Properties

- (MLClientState *)currentClientState
{
    return nil;// clientStateRequestHandler_.currentClientState;
}

- (NSNumber *)currentUserId
{
    return self.auth.userId;
}

@end
