//
//  AssetToDataConverter.h
//  Video
//
//  Created by Apple on 8/10/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PHAsset;
typedef void (^conversionComplete) (NSData *data, NSString *path);

@interface AssetToDataConverter : NSObject
+ (void)convertAsset:(PHAsset *)asset completion:(conversionComplete)completion;
@end
