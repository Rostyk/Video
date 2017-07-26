//
//  SDUserSettings.m
//  

#import <UIKit/UIKit.h>
#import "SDUserSettings.h"

//const  NSString *SDDefaultServiceURL                    = @"";

const  NSString *SDDefaultSystemToken                   = @"token";

static NSString * const SDUserName                      = @"userName";
static NSString * const SDAccessToken                   = @"accessToken";
static NSString * const SDUserId                        = @"userId";
static NSString * const SDPracticeId                    = @"practiceId";


const CGFloat SDDefaultAnimationDuration = 0.3;
const NSUInteger SDCancelButtonIndex = 0;

const NSUInteger FDFeedCaptionMaxLength = 255;

@interface SDUserSettings ()

+ (NSString *)URLStringWithRoot:(NSString *)root path:(NSString const *)path;

@end


@implementation SDUserSettings

+ (NSString *)URLStringWithRoot:(NSString *)root path:(NSString const *)path
{
    NSUInteger firstSlashIndex = [path rangeOfString:@"/"].location;
    
    NSString *tempPath;
    if (firstSlashIndex != NSNotFound)
    {
        tempPath = [NSString stringWithFormat:@"%@%@", [path substringToIndex:firstSlashIndex], [path substringFromIndex:firstSlashIndex]];
    }
    else
    {
        tempPath = [NSString stringWithFormat:@"%@", path];
    }
    
    return root.length > 0 ? [NSString stringWithFormat:[root hasSuffix:@"/"] ? @"%@%@" : @"%@/%@", root, tempPath] : nil;
}

+ (NSString *)serviceURL
{
    NSString *basicURL = /*@"http://52.88.119.213:3000"*/ @"https://api.automatize.chernetsov.space";
    return basicURL;
}

#pragma mark -

+ (void)setUserName:(NSString *)userName
{
    if (userName.length <= 0)
    {
        [SDUserSettings setUserId:nil];
        [SDUserSettings setAccessToken:nil];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:userName forKey:SDUserName];
    [defaults synchronize];
}

+ (NSString *)userName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    return [defaults objectForKey:SDUserName];
}

+ (void)setAccessToken:(NSString *)accessToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:accessToken forKey:SDAccessToken];
    [defaults synchronize];
}

+ (NSString *)accessToken
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    return [defaults objectForKey:SDAccessToken];
}

+ (void)setUserId:(NSNumber *)userId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:userId forKey:SDUserId];
    [defaults synchronize];
}

+ (NSNumber *)userId
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    return [defaults objectForKey:SDUserId];
}

@end
