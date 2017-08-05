#import "MTUser.h"

@interface MTUser ()

// Private interface goes here.

@end

@implementation MTUser

// Custom logic goes here.
- (void)parseNode:(NSDictionary *)node {
    self.accessToken = node[@"access_token"];
}
@end
