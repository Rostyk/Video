//
//  NSString+SDAdditions.m
//  

#import "NSString+MTAdditions.h"


static NSUInteger EPLimitedFileNameFirstPartLength = 40;
static NSUInteger EPLimitedFileNameLastPartLength = 8;


@implementation NSString (MTStringAdditions)

- (BOOL)isEmailAddress {
    NSString *emailRegex = @"[[A-Z0-9a-z~._%+-][}{?|/'=`*&!#$^]]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex]; 
    
    return [emailTest evaluateWithObject:self];
}

- (BOOL)isValidName {
    return [self rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\\/:*?<>|"]].location == NSNotFound;
}

- (NSString *)URLEncodedString {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    unsigned long sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

- (NSString *)JSONEncodedString {
    NSMutableString *outputString = [[NSMutableString alloc] init];
    for (int i = 0; i < [self length]; i ++) {
        unichar symbol;
        [self getCharacters:&symbol range:NSMakeRange(i, 1)];
        switch (symbol) {
            case '\\': 
                    [outputString appendString:@"\\\\"];
                    break;
            case '\"': 
                    [outputString appendString:@"\\\""];
                    break;
            /*
            case '/': 
                    [outputString appendString:@"%x2F"];
                    break;
            case '\n': 
                    [outputString appendString:@"%x6E"];
                    break;
            case '\t': 
                    [outputString appendString:@"%x74"];
                    break;
            case '\b': 
                    [outputString appendString:@"%x62"];
                    break;
            case '\r': 
                    [outputString appendString:@"%x72"];
                    break;
            case '\f': 
                    [outputString appendString:@"%x66"];
                    break;
            */
            default:
                [outputString appendFormat:@"%C",symbol];
                break;
        }
    }
    
    return [outputString copy];
}

- (BOOL)isRestrictedFileName {
    static NSSet *restrictedNames = nil;
    if (restrictedNames == nil) {
        @synchronized (self) {
            restrictedNames = [[NSSet alloc] initWithObjects:@"CON", @"PRN", @"AUX", @"CLOCK$", @"NUL",
                               @"COM0", @"COM1", @"COM2", @"COM3", @"COM4", @"COM5", @"COM6",
                               @"COM7", @"COM8", @"COM9", @"LPT0", @"LPT1", @"LPT2", @"LPT3",
                               @"LPT4", @"LPT5", @"LPT6", @"LPT7", @"LPT8", @"LPT9", nil];
        }
    }
    return [restrictedNames containsObject:[[self stringByDeletingPathExtension] uppercaseString]];
}

- (NSString *)trimedString {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)limitedLengthFileName {
    NSString *result = self;
    if (self.length > EPLimitedFileNameFirstPartLength + EPLimitedFileNameLastPartLength) {
        result = [NSString stringWithFormat:@"%@...%@",
                  [self substringToIndex:EPLimitedFileNameFirstPartLength],
                  [self substringFromIndex:self.length - EPLimitedFileNameLastPartLength]];
    }
    return result;
}

@end
