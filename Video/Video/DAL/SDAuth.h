//
//  SDAuth.h
//  

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>


@class SDAuth;
@class SDResult;

@protocol SDAuthDelegate <NSObject>

- (void)didSucceedAuthentication:(SDAuth *)authentication keepAlive:(BOOL)keepAlive;
- (void)didCancelAuthentication:(SDAuth *)authentication;

- (void)authentication:(SDAuth *)authentication didFailWithError:(SDResult *)error;

@end


@interface SDAuth : NSObject

@property (nonatomic, copy) NSString *serviceURL;
@property (nonatomic, assign) id<SDAuthDelegate> delegate;
@property (nonatomic, readonly, getter = isAuthenticating) BOOL authenticationInProgress;
@property (nonatomic, readonly, getter = isAuthenticated) BOOL authenticated;
@property (nonatomic, strong, readonly) NSString *securityToken;
@property (nonatomic, strong, readonly) NSDate *tokenValidTill;
@property (nonatomic, strong, readonly) NSString *userName;
@property (nonatomic, strong, readonly) NSNumber *userId;

- (id)initWithServiceURL:(NSString *)serviceURL;
- (id)initWithServiceURL:(NSString *)serviceURL delegate:(id<SDAuthDelegate>)delegate;

- (void)authenticateWithUserName:(NSString *)userName passwordHash:(NSString *)passwordHash;
- (void)drop;
- (void)logout;

- (void)refreshToken;

+ (NSString *)hashWithPassword:(NSString *)password;

@end
