//
//  TIManagedObjectContextProvider.m
//  ipNonCDTest
//
//  Created by Tim Isted on 15/06/2010.
//  Copyright 2010 Tim Isted. All rights reserved.
//

#import "TIManagedObjectContextProvider.h"

@interface TIManagedObjectContextProvider ()

- (void)_notifyDelegateAndSetError:(NSError *)anError;

@end


@implementation TIManagedObjectContextProvider

#pragma mark -
#pragma mark Errors
- (void)_notifyDelegateAndSetError:(NSError *)anError
{
    [self setMostRecentError:anError];
    
    if( [[self delegate] respondsToSelector:@selector(managedObjectContextProvider:receivedError:)] )
        [[self delegate] managedObjectContextProvider:self receivedError:anError];
}

#pragma mark -
#pragma mark Lazy Accessors
- (NSManagedObjectContext *)managedObjectContext
{
    if( _managedObjectContext ) return _managedObjectContext;
    
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
    
    return _managedObjectContext;
}

- (NSManagedObjectContext *)secondaryManagedObjectContext
{
    NSManagedObjectContext *secondaryContext = [[NSManagedObjectContext alloc] init];
    [secondaryContext setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
    
    return [secondaryContext autorelease];
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if( _persistentStoreCoordinator ) return _persistentStoreCoordinator;
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSURL *urlForStore = [NSURL fileURLWithPath:[self storeDataPath]];
    
    [self setMostRecentError:nil];
    NSError *error = nil;
    NSPersistentStore *store = [_persistentStoreCoordinator addPersistentStoreWithType:[self persistentStoreType] 
                                                                         configuration:nil URL:urlForStore 
                                                                               options:[self persistentStoreOptions] error:&error];
    if( !store ) [self _notifyDelegateAndSetError:error];

    return _persistentStoreCoordinator;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if( _managedObjectModel ) return _managedObjectModel;
    
    _managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];
    
    return _managedObjectModel;
}

- (NSString *)storeDataPath
{
    if( _storeDataPath ) return _storeDataPath;

#if TARGET_OS_MAC && !(TARGET_OS_IPHONE)
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *directory = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    directory = [directory stringByAppendingPathComponent:[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey]];
    
    [self setMostRecentError:nil];
    NSError *error = nil;
    
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:NULL] ) {
		if (![[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:NO attributes:nil error:&error]) {
            [self _notifyDelegateAndSetError:error];
		}
    }
#else
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
#endif
    _storeDataPath = [[directory stringByAppendingPathComponent:[self storeDataFileName]] retain];
    
    return _storeDataPath;
}

- (NSString *)storeDataFileName
{
    if( _storeDataFileName ) return _storeDataFileName;
    
    NSString *fileName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
    if( [[self persistentStoreType] isEqualToString:NSSQLiteStoreType] )
        fileName = [fileName stringByAppendingPathExtension:@"sqlite"];
#if TARGET_OS_MAC && !(TARGET_OS_IPHONE)
    else if( [[self persistentStoreType] isEqualToString:NSXMLStoreType] )
        fileName = [fileName stringByAppendingPathExtension:@"xml"];
#endif
    _storeDataFileName = [fileName retain];
    
    return _storeDataFileName;
}

- (NSString *)persistentStoreType
{
    if( _persistentStoreType ) return _persistentStoreType;
    
    _persistentStoreType = NSSQLiteStoreType;
    
    return _persistentStoreType;
}

- (NSDictionary *)persistentStoreOptions
{
    if( _persistentStoreOptions ) return _persistentStoreOptions;
    
    _persistentStoreOptions = [[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption] retain];
    return _persistentStoreOptions;
}

#pragma mark -
#pragma mark Initialization and Deallocation
- (id)init
{
    return [super init];
}

+ (id)managedObjectContextProvider
{
    return [[[self alloc] init] autorelease];
}

- (void)dealloc
{
    [_managedObjectContext release];
    [_persistentStoreCoordinator release];
    [_managedObjectModel release];
    
    [_storeDataFileName release];
    [_storeDataPath release];
    
    [_persistentStoreOptions release];
    
    [_mostRecentError release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Properties
@synthesize delegate = _delegate;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;

@synthesize storeDataFileName = _storeDataFileName;
@synthesize storeDataPath = _storeDataPath;

@synthesize persistentStoreType = _persistentStoreType;
@synthesize persistentStoreOptions = _persistentStoreOptions;

@synthesize mostRecentError = _mostRecentError;

@end
