//
//  SDMultipartRequestUtility.m
//  Automatize
//
//  Created by Rostyslav.Stepanyak on 3/17/17.
//  Copyright © 2017 Tilf AB. All rights reserved.
//

#import "SDMultipartRequestUtility.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "MultipartItem.h"
#import <UIKit/UIKit.h>

@implementation SDMultipartRequestUtility

- (NSString *)mimeTypeForPath:(NSString *)path
{
    // get a mime type for an extension using MobileCoreServices.framework
    if (!path)
        path = @"image.jpg";
    
    CFStringRef extension = (__bridge CFStringRef)[path pathExtension];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, extension, NULL);
    assert(UTI != NULL);
    
    NSString *mimetype = CFBridgingRelease(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
    assert(mimetype != NULL);
    
    CFRelease(UTI);
    
    return mimetype;
}

- (NSString *)generateBoundaryString
{
    return [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
}

- (NSData *)videoDataAtPath:(NSString *)path {
    return nil;
}

- (NSMutableData *)createBodyWithBoundary:(NSString *)boundary
                        parameters:(NSDictionary *)parameters
                             path:(NSString *)path
                        videoData:(NSData *)videoData
                         fieldName:(NSString *)fieldName {
    
    NSMutableData *httpBody = [NSMutableData data];
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    NSString *filename  = [path lastPathComponent];
    NSData   *data      = videoData;
    NSString *mimetype  = [self mimeTypeForPath:path];
        
    [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", fieldName, filename] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n", mimetype] dataUsingEncoding:NSUTF8StringEncoding]];
    [httpBody appendData:data];
    [httpBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *str = [[NSString alloc] initWithData:httpBody encoding:NSASCIIStringEncoding];
    NSLog(@"Certificate body: %@", str);
    return httpBody;
}

- (NSString *) getHTTPBodyParamsFromDictionary: (NSDictionary *)params boundary:(NSString *)boundary
{
    NSMutableString *tempVal = [[NSMutableString alloc] init];
    for(NSString * key in params)
    {
        [tempVal appendFormat:@"\r\n--%@\r\n", boundary];
        [tempVal appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@",key,[params objectForKey:key]];
    }
    return [tempVal description];
}

@end
