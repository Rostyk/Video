// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTUser.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface MTUserID : NSManagedObjectID {}
@end

@interface _MTUser : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) MTUserID *objectID;

@property (nonatomic, strong, nullable) NSString* accessToken;

@end

@interface _MTUser (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSString*)primitiveAccessToken;
- (void)setPrimitiveAccessToken:(nullable NSString*)value;

@end

@interface MTUserAttributes: NSObject 
+ (NSString *)accessToken;
@end

NS_ASSUME_NONNULL_END
