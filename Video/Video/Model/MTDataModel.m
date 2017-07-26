//
//  MTDataModel.m
//  rent
//
//  Created by Nick Savula on 6/4/15.
//  Copyright (c) 2015 Maliwan Technology. All rights reserved.
//

#import <CoreData/CoreData.h>

#import "MTDataModel.h"

#import "NSObject+PNCast.h"


@interface MTDataModel ()

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation MTDataModel

@synthesize managedObjectContext = managedObjectContext_;
@synthesize managedObjectModel = managedObjectModel_;
@synthesize persistentStoreCoordinator = persistentStoreCoordinator_;

- (void)dealloc
{
    [self resetCoreData];
}

#pragma mark - Core Data

- (NSManagedObjectContext *)managedObjectContext
{
    if (managedObjectContext_ == nil)
    {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        
        if (coordinator != nil)
        {
            managedObjectContext_ = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            [managedObjectContext_ setPersistentStoreCoordinator:coordinator];
        }
    }
    
    return managedObjectContext_;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (managedObjectModel_ == nil)
    {
        managedObjectModel_ = [NSManagedObjectModel mergedModelFromBundles:nil];
        
        //NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
        //managedObjectModel_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    
    
    return managedObjectModel_;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (persistentStoreCoordinator_ == nil)
    {
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"maliwanData.sqlite"];
        
        NSError *error = nil;
        persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        
        if (![persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
        {
            // WORKAROUND: just removing old storage for convenience of development
            // TODO: simple development make merging of old database with new schema, when model becomes versioned
            NSLog(@"Error opening persistent store %@:%@", storeURL, error);
            switch ([error code])
            {
                case NSPersistentStoreIncompatibleSchemaError:
                case NSPersistentStoreIncompatibleVersionHashError:
                    
                    persistentStoreCoordinator_ = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
                    [persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];
                    
                    error = nil;
                    NSLog(@"Trying to recover by removing old storage..");
                    
                    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
                    if (!error && [persistentStoreCoordinator_ addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
                    {
                        NSLog(@"OK. New persistant storage was created.");
                        return persistentStoreCoordinator_;
                    };
                    
                    break;
            }
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    return persistentStoreCoordinator_;
}

- (void)resetCoreData
{
    managedObjectContext_ = nil;
    managedObjectModel_ = nil;
    persistentStoreCoordinator_ = nil;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

// Convenience method to fetch the array of objects for a given Entity
// name in the context, optionally limiting by a predicate or by a predicate
// made from a format NSString and variable arguments.
//
- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName
                       withPredicate:(NSPredicate *)predicate
{
    NSArray *results = [NSArray array];
    
    NSEntityDescription *entity = [[self.managedObjectModel entitiesByName] objectForKey:newEntityName];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    
    [request setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES]]];
    
    if(predicate) {
        [request setPredicate:predicate];
    }

    NSError *error = nil;
    results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error != nil)
    {
        [NSException raise:NSGenericException format:@"%@", [error description]];
    }
    
    return results;
}

- (NSManagedObject *)emptyNode:(Class)className
{
    if ([className respondsToSelector:@selector(entityName)])
    {
        NSEntityDescription *description = [self.managedObjectModel entitiesByName][[(id)className entityName]];
        
        return [[className alloc] initWithEntity:description
                  insertIntoManagedObjectContext:self.managedObjectContext];
    }
    
    return nil;
}

#pragma mark - public

+ (MTDataModel *)sharedDatabaseStorage
{
    static MTDataModel *sharedInstance = nil;
    static dispatch_once_t pred;
    
    if (!sharedInstance)
    {
        dispatch_once(&pred, ^{
            sharedInstance = [MTDataModel alloc];
            sharedInstance = [sharedInstance init];
        });
    }
    
    return sharedInstance;
}

#pragma mark - fetch requests
/*- (NSString *)getAccessToken {
    __block NSString *token = nil;
    if ([NSThread isMainThread]) {
        NSFetchRequest *allUsers = [[NSFetchRequest alloc] init];
        [allUsers setEntity:[NSEntityDescription entityForName:@"MTUser" inManagedObjectContext:self.managedObjectContext]];
        
        NSError *error = nil;
        NSArray *users = [self.managedObjectContext executeFetchRequest:allUsers
                                                                  error:&error];
        
        token = [((MTUser *)users.firstObject).accessToken copy];
    }
    else {
        __weak typeof (self) weakSelf = self;
        [self.managedObjectContext performBlock:^{
            NSFetchRequest *allUsers = [[NSFetchRequest alloc] init];
            [allUsers setEntity:[NSEntityDescription entityForName:@"MTUser" inManagedObjectContext:self.managedObjectContext]];
            
            NSError *error = nil;
            NSArray *users = [weakSelf.managedObjectContext executeFetchRequest:allUsers
                                                                          error:&error];
            token = [((MTUser *)users.firstObject).accessToken copy];
        }];
    }
    
    return token;
}*/

/*
- (NSString *)getAccessToken {
    NSFetchRequest *allUsers = [[NSFetchRequest alloc] init];
    [allUsers setEntity:[NSEntityDescription entityForName:@"MTUser" inManagedObjectContext:self.managedObjectContext]];
    
    NSError *error = nil;
    NSArray *users = [self.managedObjectContext executeFetchRequest:allUsers
                                                              error:&error];
    
    return [((MTUser *)users.firstObject).accessToken copy];
}

- (MTDelivery *)getDeliveryDetails:(BOOL)isAssigned {
    NSFetchRequest *allDetails = [[NSFetchRequest alloc] init];
    [allDetails setEntity:[NSEntityDescription entityForName:@"MTDelivery" inManagedObjectContext:self.managedObjectContext]];
    
    NSError *error = nil;
    NSArray *details = [self.managedObjectContext executeFetchRequest:allDetails
                                                                error:&error];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isAssigned == %@", [NSNumber numberWithBool:isAssigned]];
    NSArray *filteredDetails = [details filteredArrayUsingPredicate:predicate];

    
    return [filteredDetails firstObject];
}

- (NSArray *)getPastLogs {
    NSFetchRequest *allLogs = [[NSFetchRequest alloc] init];
    [allLogs setEntity:[NSEntityDescription entityForName:@"MTLog"
                                   inManagedObjectContext:self.managedObjectContext]];
    
    NSError *error = nil;
    NSArray *logs = [self.managedObjectContext executeFetchRequest:allLogs
                                                             error:&error];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isPresent == %@", [NSNumber numberWithBool:NO]];
    NSArray *pastLogs = [logs filteredArrayUsingPredicate:predicate];
    
    return [pastLogs copy];
}

- (NSArray *)getDistricts:(NSString *)carrierId {
    NSFetchRequest *allDistricts = [[NSFetchRequest alloc] init];
    [allDistricts setEntity:[NSEntityDescription entityForName:@"MTDistrict"
                                   inManagedObjectContext:self.managedObjectContext]];
    
    NSError *error = nil;
    NSArray *districts = [self.managedObjectContext executeFetchRequest:allDistricts
                                                             error:&error];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"carrierId == %@", carrierId];
    NSArray *filteredDistricts = [districts filteredArrayUsingPredicate:predicate];
    
    return [filteredDistricts copy];
}

- (MTLog *)getPresentLog {
    NSFetchRequest *allLogs = [[NSFetchRequest alloc] init];
    [allLogs setEntity:[NSEntityDescription entityForName:@"MTLog"
                                   inManagedObjectContext:self.managedObjectContext]];
    
    NSError *error = nil;
    NSArray *logs = [self.managedObjectContext executeFetchRequest:allLogs
                                                             error:&error];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isPresent == %@", [NSNumber numberWithBool:YES]];
    NSArray *presentLogs = [logs filteredArrayUsingPredicate:predicate];
    
    return presentLogs.firstObject;
}


- (MTProfile *)getProfile {
    NSFetchRequest *allLogs = [[NSFetchRequest alloc] init];
    [allLogs setEntity:[NSEntityDescription entityForName:@"MTProfile"
                                   inManagedObjectContext:self.managedObjectContext]];
    
    NSError *error = nil;
    NSArray *profiles = [self.managedObjectContext executeFetchRequest:allLogs
                                                             error:&error];
    
    
    return profiles.firstObject;
}

#pragma mark - parsing routines

- (NSString *)parseLogin:(NSData *)data {
    [self removeAllEntities:@"MTUser"];
    MTUser *user = nil;
    if(data != nil) {
        NSError *error = nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        if (!error && [jsonDict isKindOfClass:NSDictionary.class])
        {
            user = (MTUser *)[self emptyNode:MTUser.class];
            [user parseNode:jsonDict];
        }
    }
    [self saveContext];
    
    return [user.accessToken copy];
}

- (MTPreviousVehicle *)parsePreviousVehicle:(NSData *)data {
    [self removeAllEntities:@"MTPreviousVehicle"];
    MTPreviousVehicle *previousVehicle = nil;
    if(data != nil) {
        NSError *error = nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        if (!error && [jsonDict isKindOfClass:NSDictionary.class])
        {
            previousVehicle = (MTPreviousVehicle *)[self emptyNode:MTPreviousVehicle.class];
            [previousVehicle parseNode:jsonDict];
        }
    }
    [self saveContext];
    
    return previousVehicle;
}

- (MTDelivery *)parseDeliveryDetails:(NSData *)data isAssigned:(BOOL)isAssigned{
    [self removeDeliveryObjects:@"MTDelivery" isAssigned:isAssigned];
    MTDelivery *delivery = nil;
    if(data != nil) {
        NSError *error = nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        if (!error && [jsonDict isKindOfClass:NSDictionary.class])
        {
            delivery = (MTDelivery *)[self emptyNode:MTDelivery.class];
            [delivery parseNode:jsonDict];
            
            delivery.isAssigned = @(isAssigned);
            
            MTDeliveryDestination *destination = (MTDeliveryDestination *)[self emptyNode:MTDeliveryDestination.class];
            [destination parseNode:[jsonDict[@"data"][@"destination"] firstObject]];
            [delivery setDestination:destination];
            
            MTDeliveryOrigin *origin = (MTDeliveryOrigin *)[self emptyNode:MTDeliveryOrigin.class];
            [origin parseNode:[jsonDict[@"data"][@"origin"] firstObject]];
            [delivery setOrigin:origin];
            
            MTDeliveryDetails *details = (MTDeliveryDetails *)[self emptyNode:MTDeliveryDetails.class];
            [details parseNode:[jsonDict[@"data"][@"orderDetails"] firstObject]];
            [delivery setDetails:details];
            
            NSArray *sandTickets = jsonDict[@"data"][@"sandTicket"];
            for (NSDictionary *ticketDictionary in sandTickets) {
                MTDeliverySandTicket *deliveryTicket = (MTDeliverySandTicket *)[self emptyNode:MTDeliverySandTicket.class];
                [deliveryTicket parseNode:ticketDictionary];
                [delivery addSandTicketsObject:deliveryTicket];
            }
            
            NSArray *certsDictionaries = jsonDict[@"data"][@"necesseryCertificates"];
            for (NSDictionary *certsDictionary in certsDictionaries) {
                MTCert *cert = (MTCert *)[self emptyNode:MTCert.class];
                [cert parseNode:certsDictionary];
                [delivery addCertificatesObject:cert];
            }
        }
    }
    [self saveContext];
    
    return delivery;
}

- (MTProfile *)parseProfile:(NSData *)data {
    [self removeAllEntities:@"MTProfile"];
    MTProfile *profile = nil;
    if(data != nil) {
        NSError *error = nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        if (!error && [jsonDict isKindOfClass:NSDictionary.class])
        {
            profile = (MTProfile *)[self emptyNode:MTProfile.class];
            [profile parseNode:jsonDict[@"data"]];
        }
    }
    [self saveContext];
    
    return profile;
}

- (NSArray *)parseLogs:(NSData *)data {
    [self removeAllEntities:@"MTLog"];
    NSMutableArray *logsArray = [[NSMutableArray alloc] init];
    if(data != nil) {
        NSError *error = nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        if (!error && [jsonDict isKindOfClass:NSDictionary.class])
        {
            NSArray *pastRecords = jsonDict[@"data"][@"pastRecords"];
            for (NSDictionary *pastRecord in pastRecords) {
                MTLog *log = nil;
                log = (MTLog *)[self emptyNode:MTLog.class];
                [log parseNode:pastRecord
                     isPresent:false];
                [logsArray addObject:log];
            }
            
            NSArray *presentRecords = jsonDict[@"data"][@"presentRecord"];
            for (NSDictionary *presentRecord in presentRecords) {
                MTLog *log = nil;
                log = (MTLog *)[self emptyNode:MTLog.class];
                [log parseNode:presentRecord
                     isPresent:true];
                [logsArray addObject:log];
            }
        }
    }
    [self saveContext];
    
    return [logsArray copy];
}

- (NSArray *)parseDistricts:(NSData *)data {
    NSMutableArray *districts = [[NSMutableArray alloc] init];
    if(data != nil) {
        NSError *error = nil;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        if (!error && [jsonDict isKindOfClass:NSDictionary.class])
        {
            NSArray *districtDictionaries = jsonDict[@"data"][@"district"];
            for (NSDictionary *disctrictDict in districtDictionaries) {
                MTDistrict *district = nil;
                district = (MTDistrict *)[self emptyNode:MTDistrict.class];
                [district parseNode:disctrictDict];
                [districts addObject:district];
            }
        }
    }
    [self saveContext];
    
    return [districts copy];
}

- (void)clearDistricts {
    [self removeAllEntities:@"MTDistrict"];
}

#pragma mark - removing objects

- (void)removeDeliveryObjects:(NSString *)entity isAssigned:(BOOL)isAssigned {
    NSFetchRequest *allProducts = [[NSFetchRequest alloc] init];
    [allProducts setEntity:[NSEntityDescription entityForName:entity inManagedObjectContext:self.managedObjectContext]];
    [allProducts setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error = nil;
    NSArray *objects = [self.managedObjectContext executeFetchRequest:allProducts error:&error];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isAssigned == %@", [NSNumber numberWithBool:isAssigned]];
    NSArray *filteredDetails = [objects filteredArrayUsingPredicate:predicate];
    
    //error handling goes here
    for (NSManagedObject *object in filteredDetails) {
        [self.managedObjectContext deleteObject:object];
    }
    [self saveContext];
    
    
}
- (void)removeAllEntities:(NSString *)entity {
    NSFetchRequest *allProducts = [[NSFetchRequest alloc] init];
    [allProducts setEntity:[NSEntityDescription entityForName:entity inManagedObjectContext:self.managedObjectContext]];
    [allProducts setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error = nil;
    NSArray *objects = [self.managedObjectContext executeFetchRequest:allProducts error:&error];
    //error handling goes here
    for (NSManagedObject *object in objects) {
        [self.managedObjectContext deleteObject:object];
    }
    [self saveContext];
}

- (void)removeToken {
    [self removeAllEntities:@"MTUser"];
}
*/
#pragma mark - save

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
