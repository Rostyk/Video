#import "MTVideo.h"

@interface MTVideo ()

// Private interface goes here.

@end

@implementation MTVideo

// Custom logic goes here.

- (void)parseNode:(NSDictionary *)node {
    self.url = node[@"url"];
    self.category = node[@"categoryName"];
    self.isExpired = node[@"isExpire"];
    self.videoId = node[@"id"];
    self.views = node[@"views"];
    self.title = node[@"title"];
    self.details = node[@"description"];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy hh:mm:ss a"];
    
    NSDate *date = [formatter dateFromString:node[@"date"]];
    self.date = date;
}

@end
