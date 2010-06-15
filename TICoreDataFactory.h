//
//  TIManagedObjectContextProvider.h
//  ipNonCDTest
//
//  Created by Tim Isted on 15/06/2010.
//  Copyright 2010 Tim Isted. All rights reserved.
//

#import <CoreData/CoreData.h>

@protocol TICoreDataFactoryDelegate;


@interface TICoreDataFactory : NSObject {
    __weak NSObject <TICoreDataFactoryDelegate> *_delegate;
    
    NSManagedObjectContext *_managedObjectContext;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    NSManagedObjectModel *_managedObjectModel;
    
    NSString *_persistentStoreDataFileName;
    NSString *_persistentStoreDataPath;
    
    NSString *_persistentStoreType;
    NSDictionary *_persistentStoreOptions;
    
    NSError *_mostRecentError;
}

+ (id)coreDataFactory;

- (NSManagedObjectContext *)secondaryManagedObjectContext;

@property (nonatomic, assign) NSObject <TICoreDataFactoryDelegate> *delegate;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;

@property (nonatomic, retain) NSString *persistentStoreDataFileName;
@property (nonatomic, retain) NSString *persistentStoreDataPath;

@property (nonatomic, assign) NSString *persistentStoreType;
@property (nonatomic, retain) NSDictionary *persistentStoreOptions;

@property (nonatomic, retain) NSError *mostRecentError;

@end


@protocol TICoreDataFactoryDelegate
@optional
- (void)coreDataFactory:(TICoreDataFactory *)aFactory encounteredError:(NSError *)anError;

@end