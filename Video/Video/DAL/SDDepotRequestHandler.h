//
//  SDDepotRequestHandler.h
//  

#import <Foundation/Foundation.h>
#import "SDRequestHandler.h"


@interface SDDepotRequestHandler : SDRequestHandler
{
@private
    NSMutableSet *currentRequests_;
}

@end
