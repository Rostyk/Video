//
//  AssetToDataConverter.m
//  Video
//
//  Created by Apple on 8/10/17.
//  Copyright © 2017 Rostyslav.Stepanyak. All rights reserved.
//

#import "AssetToDataConverter.h"
@import Photos;

@implementation AssetToDataConverter

+ (void)convertAsset:(PHAsset *)asset completion:(conversionComplete)completion {
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:nil resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
        NSURL *url = (NSURL *)[[(AVURLAsset *)avAsset URL] fileReferenceURL];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSError* error = nil;
            NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(data, [url.absoluteString stringByAppendingString:@".mp4"]);
            });
        });
    }];
}

@end
