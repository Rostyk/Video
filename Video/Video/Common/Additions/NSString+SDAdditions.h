//
//  NSString+SDAdditions.h
//  

#import <Foundation/Foundation.h>


@interface NSString (SDStringAdditions)
    
- (BOOL)isEmailAddress;
- (BOOL)isValidName;

- (NSString *)URLEncodedString;

- (NSString *)JSONEncodedString;
- (BOOL)isRestrictedFileName;

- (NSString *)trimedString;

- (NSString *)limitedLengthFileName;

@end
