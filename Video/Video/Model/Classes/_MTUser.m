// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTUser.m instead.

#import "_MTUser.h"

@implementation MTUserID
@end

@implementation _MTUser

+ (instancetype)insertInManagedObjectContext:(NSManagedObjectContext *)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MTUser" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MTUser";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MTUser" inManagedObjectContext:moc_];
}

- (MTUserID*)objectID {
	return (MTUserID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	return keyPaths;
}

@dynamic accessToken;

@end

@implementation MTUserAttributes 
+ (NSString *)accessToken {
	return @"accessToken";
}
@end

