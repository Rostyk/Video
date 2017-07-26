//
//  MLResult.m

#import "SDResult.h"

#import "Strings.h"


@implementation SDResult

@synthesize message = message_;

#pragma mark - Memory management

- (id)initWithType:(SDResultType)type domain:(SDResultDomain)domain code:(NSInteger)code message:(NSString *)message
{
    self = [super init];
    
    if (self)
    {
        result_.type_ = type;
        result_.domain_ = domain;
        result_.code_ = code;
        message_ = [message copy];
    }
    
    return self;
}

#pragma mark - Static methods

+ (SDResult *)success
{
    return [[SDResult alloc] initWithType:SDResultSuccess domain:SDResultDomainApp code:0 message:nil];
}

+ (SDResult *)errorWithDomain:(NSInteger)domain code:(NSInteger)code message:(NSString *)message
{
    return [[SDResult alloc] initWithType:SDResultError domain:(SDResultDomain)domain code:code message:message];
}

+ (SDResult *)errorWithCode:(NSInteger)code message:(NSString *)message
{
    return [SDResult errorWithDomain:SDResultDomainApp code:code message:message];
}

+ (SDResult *)errorWithCode:(NSInteger)code
{
    NSString *message = nil;
    
    if (code == 0)
    {
        message = @"No internet connection"; // LOC_ERR_INTERNET_CONNECTION;
    }
    
    return [SDResult errorWithDomain:SDResultDomainApp code:code message:message];
}

+ (SDResult *)warningWithDomain:(NSInteger)domain code:(NSInteger)code message:(NSString *)message
{
    return [[SDResult alloc] initWithType:SDResultWarning domain:(SDResultDomain)domain code:code message:message];
}

+ (SDResult *)warningWithCode:(NSInteger)code message:(NSString *)message
{
    return [SDResult warningWithDomain:SDResultDomainApp code:code message:message];
}

+ (SDResult *)warningWithCode:(NSInteger)code
{
    return [SDResult warningWithDomain:SDResultDomainApp code:code message:nil];
}

+ (NSString *)messageWithCode:(NSInteger)code
{
    return nil;
}

#pragma mark - Properties

- (SDResultType)type
{
    return result_.type_;
}

- (SDResultDomain)domain
{
    return result_.domain_;
}

- (NSInteger)code
{
    return result_.code_;
}

- (NSString *)message
{
    return message_ != nil ? message_ : [SDResult messageWithCode:result_.code_];
}

#pragma mark - Methods

- (BOOL)isSuccess
{
    return result_.type_ != SDResultError;
}

- (void)parseResponseData:(NSData *)responseData
{
}

@end
