//
//  MTDataModel.h
//  rent
//
//  Created by Nick Savula on 6/4/15.
//  Copyright (c) 2015 Maliwan Technology. All rights reserved.
//

#import <Foundation/Foundation.h>

// NOTE: to update models:  mogenerator -m MTDataModel.xcdatamodel/ -O ../Classes/ --template-var arc=YES


@interface MTDataModel : NSObject

+ (MTDataModel *)sharedDatabaseStorage;

- (void)saveContext;

- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName
                         withPredicate:(NSPredicate *)predicate;

/*
- (NSString *)parseLogin:(NSData *)data;
- (MTPreviousVehicle *)parsePreviousVehicle:(NSData *)data;
- (MTDelivery *)parseDeliveryDetails:(NSData *)data
                          isAssigned:(BOOL)isAssigned;
- (NSArray *)parseLogs:(NSData *)data;
- (NSArray *)getDistricts:(NSString *)carrierId;
- (NSArray *)parseDistricts:(NSData *)data;
- (void)clearDistricts;

- (MTProfile *)parseProfile:(NSData *)data;

- (NSArray *)getPastLogs;
- (MTLog *)getPresentLog;
- (NSString *)getAccessToken;
- (MTDelivery *)getDeliveryDetails:(BOOL)isAssigned;
- (MTProfile *)getProfile;

- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName
                         withPredicate:(NSPredicate *)predicate;
- (void)removeToken;*/
@end
