//
//  MultipartItem.h
//  Automatize
//
//  Created by Rostyslav.Stepanyak on 4/15/17.
//  Copyright © 2017 Tilf AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MultipartItem : NSObject
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *fieldName;
@property (nonatomic, strong) UIImage *image;
@end
