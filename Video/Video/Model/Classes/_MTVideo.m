// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTVideo.m instead.

#import "_MTVideo.h"

@implementation MTVideoID
@end

@implementation _MTVideo

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MTVideo" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MTVideo";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MTVideo" inManagedObjectContext:moc_];
}

- (MTVideoID*)objectID {
	return (MTVideoID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"isExpiredValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isExpired"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"videoIdValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"videoId"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"viewsValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"views"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic category;

@dynamic date;

@dynamic details;

@dynamic isExpired;

- (BOOL)isExpiredValue {
	NSNumber *result = [self isExpired];
	return [result boolValue];
}

- (void)setIsExpiredValue:(BOOL)value_ {
	[self setIsExpired:@(value_)];
}

- (BOOL)primitiveIsExpiredValue {
	NSNumber *result = [self primitiveIsExpired];
	return [result boolValue];
}

- (void)setPrimitiveIsExpiredValue:(BOOL)value_ {
	[self setPrimitiveIsExpired:@(value_)];
}

@dynamic originUrl;

@dynamic title;

@dynamic url;

@dynamic videoId;

- (int64_t)videoIdValue {
	NSNumber *result = [self videoId];
	return [result longLongValue];
}

- (void)setVideoIdValue:(int64_t)value_ {
	[self setVideoId:@(value_)];
}

- (int64_t)primitiveVideoIdValue {
	NSNumber *result = [self primitiveVideoId];
	return [result longLongValue];
}

- (void)setPrimitiveVideoIdValue:(int64_t)value_ {
	[self setPrimitiveVideoId:@(value_)];
}

@dynamic views;

- (int64_t)viewsValue {
	NSNumber *result = [self views];
	return [result longLongValue];
}

- (void)setViewsValue:(int64_t)value_ {
	[self setViews:@(value_)];
}

- (int64_t)primitiveViewsValue {
	NSNumber *result = [self primitiveViews];
	return [result longLongValue];
}

- (void)setPrimitiveViewsValue:(int64_t)value_ {
	[self setPrimitiveViews:@(value_)];
}

@end

@implementation MTVideoAttributes 
+ (NSString *)category {
	return @"category";
}
+ (NSString *)date {
	return @"date";
}
+ (NSString *)details {
	return @"details";
}
+ (NSString *)isExpired {
	return @"isExpired";
}
+ (NSString *)originUrl {
	return @"originUrl";
}
+ (NSString *)title {
	return @"title";
}
+ (NSString *)url {
	return @"url";
}
+ (NSString *)videoId {
	return @"videoId";
}
+ (NSString *)views {
	return @"views";
}
@end

