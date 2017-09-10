// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTVideo.h instead.

#if __has_feature(modules)
    @import Foundation;
    @import CoreData;
#else
    #import <Foundation/Foundation.h>
    #import <CoreData/CoreData.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface MTVideoID : NSManagedObjectID {}
@end

@interface _MTVideo : NSManagedObject
+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_;
+ (NSString*)entityName;
+ (nullable NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) MTVideoID *objectID;

@property (nonatomic, strong, nullable) NSNumber* categoryId;

@property (atomic) int32_t categoryIdValue;
- (int32_t)categoryIdValue;
- (void)setCategoryIdValue:(int32_t)value_;

@property (nonatomic, strong, nullable) NSDate* date;

@property (nonatomic, strong, nullable) NSString* details;

@property (nonatomic, strong, nullable) NSNumber* isExpired;

@property (atomic) BOOL isExpiredValue;
- (BOOL)isExpiredValue;
- (void)setIsExpiredValue:(BOOL)value_;

@property (nonatomic, strong, nullable) NSString* originUrl;

@property (nonatomic, strong, nullable) NSString* title;

@property (nonatomic, strong, nullable) NSString* url;

@property (nonatomic, strong, nullable) NSNumber* videoId;

@property (atomic) int64_t videoIdValue;
- (int64_t)videoIdValue;
- (void)setVideoIdValue:(int64_t)value_;

@property (nonatomic, strong, nullable) NSNumber* views;

@property (atomic) int64_t viewsValue;
- (int64_t)viewsValue;
- (void)setViewsValue:(int64_t)value_;

@end

@interface _MTVideo (CoreDataGeneratedPrimitiveAccessors)

- (nullable NSNumber*)primitiveCategoryId;
- (void)setPrimitiveCategoryId:(nullable NSNumber*)value;

- (int32_t)primitiveCategoryIdValue;
- (void)setPrimitiveCategoryIdValue:(int32_t)value_;

- (nullable NSDate*)primitiveDate;
- (void)setPrimitiveDate:(nullable NSDate*)value;

- (nullable NSString*)primitiveDetails;
- (void)setPrimitiveDetails:(nullable NSString*)value;

- (nullable NSNumber*)primitiveIsExpired;
- (void)setPrimitiveIsExpired:(nullable NSNumber*)value;

- (BOOL)primitiveIsExpiredValue;
- (void)setPrimitiveIsExpiredValue:(BOOL)value_;

- (nullable NSString*)primitiveOriginUrl;
- (void)setPrimitiveOriginUrl:(nullable NSString*)value;

- (nullable NSString*)primitiveTitle;
- (void)setPrimitiveTitle:(nullable NSString*)value;

- (nullable NSString*)primitiveUrl;
- (void)setPrimitiveUrl:(nullable NSString*)value;

- (nullable NSNumber*)primitiveVideoId;
- (void)setPrimitiveVideoId:(nullable NSNumber*)value;

- (int64_t)primitiveVideoIdValue;
- (void)setPrimitiveVideoIdValue:(int64_t)value_;

- (nullable NSNumber*)primitiveViews;
- (void)setPrimitiveViews:(nullable NSNumber*)value;

- (int64_t)primitiveViewsValue;
- (void)setPrimitiveViewsValue:(int64_t)value_;

@end

@interface MTVideoAttributes: NSObject 
+ (NSString *)categoryId;
+ (NSString *)date;
+ (NSString *)details;
+ (NSString *)isExpired;
+ (NSString *)originUrl;
+ (NSString *)title;
+ (NSString *)url;
+ (NSString *)videoId;
+ (NSString *)views;
@end

NS_ASSUME_NONNULL_END
