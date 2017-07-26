//
//  NSString+Validation.m
//  Wallmob-POS
//
//  Created by Rasmus Hummelmose on 01/04/13.
//  Copyright (c) 2013 Wallmob A/S. All rights reserved.
//

#import "NSString+Validation.h"

@implementation NSString (Validation)

+ (BOOL)emailValid:(NSString *)email
{
    NSString *emailRegex = @"[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?\\.)+[a-zA-Z0-9](?:[a-zA-Z0-9-]*[a-zA-Z0-9])?";
    NSPredicate *regExPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL validEmail = [regExPredicate evaluateWithObject:email];
    
    if (validEmail) return YES;
    else return NO;
}

+ (BOOL)validateEmail:(NSString *)candidate {
    NSString *regExPattern = @"^[A-Z0-9._%+-]+@[A-Z0-9.-]+.[A-Z]{2,4}$";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    BOOL retVal = [regEx numberOfMatchesInString:candidate options:0 range:NSMakeRange(0, [candidate length])];
    return retVal;
    
}

+ (BOOL)validatePassword:(NSString *)candidate {
    BOOL isUppercase = NO;
    NSString *regExPattern = @"^(?=.{6,})(?=.*[a-z])(?=.*[A-Z])(?=.*[\\d])(?=.*[\\W]).*$";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    BOOL retVal = [regEx numberOfMatchesInString:candidate options:0 range:NSMakeRange(0, [candidate length])];
    for (int i = 0; i < [candidate length]; i++) {
        unichar c = [candidate characterAtIndex:i];
        isUppercase = [[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:c];
        if (isUppercase == YES) {
            break;
        }
    }
    NSLog(@"retVal:%d",retVal);
    NSLog(@"isUppercase:%d",isUppercase);
    NSLog(@"test:%d",retVal && isUppercase);

    return retVal && isUppercase;

}
//[a-zA-Z]{1}
//+ (BOOL)validatePassword:(NSString *)candidate {
//    NSString *regExPattern = @"^[a-zA-Z0-9?$.+#&%@!_-]*$";
//    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
//    BOOL retVal = [regEx numberOfMatchesInString:candidate options:0 range:NSMakeRange(0, [candidate length])];
//    return retVal && [candidate length] >= 2;
//    
//}

+ (BOOL)validateURL:(NSString *)candidate {
    NSString *regExPattern = @"^[a-zA-Z0-9_-]{3,255}$";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    BOOL retVal = [regEx numberOfMatchesInString:candidate options:0 range:NSMakeRange(0, [candidate length])];
    return retVal;
    
}

+ (BOOL)validateAlbumName:(NSString *) candidate {
    NSString *regExPattern = @"^.{3,255}$";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:(NSRegularExpressionCaseInsensitive | NSRegularExpressionAllowCommentsAndWhitespace) error:nil];
    BOOL retVal = [regEx numberOfMatchesInString:candidate options:0 range:NSMakeRange(0, [candidate length])];
    return retVal && [candidate length] >= 3;
}

@end
