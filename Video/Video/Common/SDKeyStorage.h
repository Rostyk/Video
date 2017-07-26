//
//  SDKeyStorage.h
//

#import <Foundation/Foundation.h>


@interface SDKeyStorage : NSObject
{
}

+ (NSString *)passwordWithUsername:(NSString *)username;
+ (void)setPassword:(NSString *)password withUsername:(NSString *)username;
+ (void)deletePasswordWithUsername:(NSString *)username;
+ (NSString *)UUID;
@end
