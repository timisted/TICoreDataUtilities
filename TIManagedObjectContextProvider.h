//
//  TIManagedObjectContextProvider.h
//  ipNonCDTest
//
//  Created by Tim Isted on 15/06/2010.
//  Copyright 2010 Tim Isted. All rights reserved.
//

#import <CoreData/CoreData.h>

@protocol TIManagedObjectContextProviderDelegate;


@interface TIManagedObjectContextProvider : NSObject {
    __weak NSObject <TIManagedObjectContextProviderDelegate> *_delegate;
    
    NSManagedObjectContext *_managedObjectContext;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
    NSManagedObjectModel *_managedObjectModel;
    
    NSString *_storeDataFileName;
    NSString *_storeDataPath;
    
    NSString *_persistentStoreType;
    NSDictionary *_persistentStoreOptions;
    
    NSError *_mostRecentError;
}

+ (id)managedObjectContextProvider;

- (NSManagedObjectContext *)secondaryManagedObjectContext;

@property (nonatomic, assign) NSObject <TIManagedObjectContextProviderDelegate> *delegate;

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) NSManagedObjectModel *managedObjectModel;

@property (nonatomic, retain) NSString *storeDataFileName;
@property (nonatomic, retain) NSString *storeDataPath;

@property (nonatomic, assign) NSString *persistentStoreType;
@property (nonatomic, retain) NSDictionary *persistentStoreOptions;

@property (nonatomic, retain) NSError *mostRecentError;

@end


@protocol TIManagedObjectContextProviderDelegate
@optional
- (void)managedObjectContextProvider:(TIManagedObjectContextProvider *)aProvider receivedError:(NSError *)anError;

@end