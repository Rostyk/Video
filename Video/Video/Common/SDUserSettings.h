//
//  SDUserSettings.h
//  

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


extern const  NSString *SDDefaultSystemToken;

extern const CGFloat SDDefaultAnimationDuration;
extern const NSUInteger SDCancelButtonIndex;

extern const NSUInteger FDFeedCaptionMaxLength;

@interface SDUserSettings : NSObject

+ (NSString *)serviceURL;

+ (void)setUserName:(NSString *)userName;
+ (NSString *)userName;

+ (void)setAccessToken:(NSString *)accessToken;
+ (NSString *)accessToken;

+ (void)setUserId:(NSNumber *)userId;
+ (NSNumber *)userId;

@end
