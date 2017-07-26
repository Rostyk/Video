//
//  NSString+Validation.h
//  Wallmob-POS
//
//  Created by Rasmus Hummelmose on 01/04/13.
//  Copyright (c) 2013 Wallmob A/S. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Validation)

+ (BOOL)emailValid:(NSString *)email;
+ (BOOL)validateEmail:(NSString *)candidate;
+ (BOOL)validatePassword:(NSString *)candidate;
+ (BOOL)validateURL:(NSString *)candidate;
+ (BOOL)validateAlbumName:(NSString *) candidate;

@end
