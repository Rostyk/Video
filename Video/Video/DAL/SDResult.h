//
//  MLResult.h

#import <Foundation/Foundation.h>
#import "MTDataModel.h"


typedef enum
{
    SDResultSuccess,
    SDResultWarning,
    SDResultError
} SDResultType;

typedef enum
{
    SDResultDomainApp,
    SDResultDomainService
} SDResultDomain;


@interface SDResult : NSObject
{
@protected
    struct
    {
        NSUInteger  type_:2;
        NSUInteger  domain_:2;
        NSInteger   code_:28;
    } result_;

    NSString    *message_;
}

@property (nonatomic, readonly) SDResultType type;
@property (nonatomic, readonly) SDResultDomain domain;
@property (nonatomic) NSInteger code;
@property (nonatomic, readonly) NSString *message;

+ (SDResult *)success;

+ (SDResult *)errorWithDomain:(NSInteger)domain code:(NSInteger)code message:(NSString *)message;
+ (SDResult *)errorWithCode:(NSInteger)code message:(NSString *)message;
+ (SDResult *)errorWithCode:(NSInteger)code;

+ (SDResult *)warningWithDomain:(NSInteger)domain code:(NSInteger)code message:(NSString *)message;
+ (SDResult *)warningWithCode:(NSInteger)code message:(NSString *)message;
+ (SDResult *)warningWithCode:(NSInteger)code;

+ (NSString *)messageWithCode:(NSInteger)code;

- (BOOL)isSuccess;

- (void)parseResponseData:(NSData *)responseData;

- (id)initWithType:(SDResultType)type domain:(SDResultDomain)domain code:(NSInteger)code message:(NSString *)message;

@end
