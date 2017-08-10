//
//  SDMultipartRequestUtility.h
//  Automatize
//
//  Created by Rostyslav.Stepanyak on 3/17/17.
//  Copyright © 2017 Tilf AB. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDMultipartRequestUtility : NSObject

- (NSString *)generateBoundaryString;

- (NSData *)createBodyWithBoundary:(NSString *)boundary
                        parameters:(NSDictionary *)parameters
                              path:(NSString *)path
                         videoData:(NSData *)videoData
                         fieldName:(NSString *)fieldName;


@end
