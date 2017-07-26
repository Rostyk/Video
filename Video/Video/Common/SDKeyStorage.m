//
//  SDKeyStorage.m
//

#import <security/security.h>
#import "SDKeyStorage.h"
#import <UIKit/UIKit.h>

@interface SDKeyStorage ()

+ (NSMutableDictionary *)basicDictionary:(NSString *)username;

@end


@implementation SDKeyStorage

+ (NSString *)passwordWithUsername:(NSString *)username
{
    NSMutableDictionary *search = [SDKeyStorage basicDictionary:username];
	
    //search attributes
    [search setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    [search setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
    
    //searches for password
    CFDataRef result = NULL;
    SecItemCopyMatching((__bridge CFDictionaryRef) search, ( CFTypeRef*) &result);
    NSData* passDat=(__bridge_transfer NSData*) result;
    
    //gets password
    NSString *output = [[NSString alloc] initWithData:passDat encoding:NSUTF8StringEncoding];
//    CFRelease((__bridge CFTypeRef)(passDat));
    
    return output;
}

+ (void)setPassword:(NSString *)password withUsername:(NSString *)username
{
    NSMutableDictionary *keys = [SDKeyStorage basicDictionary:username];  
    
    //clears existing password
    SecItemDelete((__bridge CFDictionaryRef)keys);
    
    //encodes the password
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    [keys setObject:passwordData forKey:(__bridge id)kSecValueData];
    
    //adds dictionary to keychain
    SecItemAdd((__bridge CFDictionaryRef) keys, nil);
}

+ (void)deletePasswordWithUsername:(NSString *)username
{
    NSMutableDictionary *keys = [self basicDictionary:username];
    SecItemDelete((__bridge CFDictionaryRef)keys);
}

#pragma mark - Private

+ (NSMutableDictionary *)basicDictionary:(NSString *)username
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    [dict setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    NSData *encodedUsername = [username dataUsingEncoding:NSUTF8StringEncoding];
    [dict setObject:encodedUsername forKey:(__bridge id)kSecAttrGeneric];
    [dict setObject:encodedUsername forKey:(__bridge id)kSecAttrAccount];
    [dict setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];
    
    return dict;
}

+ (NSString *)UUID {
    NSString *deviceId = [SDKeyStorage passwordWithUsername:@"deviceId"];
    if (deviceId && deviceId.length > 0) {
        return deviceId;
    }
    else {
        NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [SDKeyStorage setPassword:deviceId
                     withUsername:@"deviceId"];
        return deviceId;
    }
}


@end
