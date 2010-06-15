//
//  TIManagedObjectContextProvider.m
//  ipNonCDTest
//
//  Created by Tim Isted on 15/06/2010.
//  Copyright 2010 Tim Isted. All rights reserved.
//

#import "TICoreDataFactory.h"

@interface TICoreDataFactory ()

- (void)_notifyDelegateAndSetError:(NSError *)anError;

@end


@implementation TICoreDataFactory

#pragma mark -
#pragma mark Errors
- (void)_notifyDelegateAndSetError:(NSError *)anError
{
    [self setMostRecentError:anError];
    
    if( [[self delegate] respondsToSelector:@selector(coreDataFactory:encounteredError:)] )
        [[self delegate] coreDataFactory:self encounteredError:anError];
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
    
    NSURL *urlForStore = [NSURL fileURLWithPath:[self persistentStoreDataPath]];
    
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

- (NSString *)persistentStoreDataPath
{
    if( _persistentStoreDataPath ) return _persistentStoreDataPath;

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
    _persistentStoreDataPath = [[directory stringByAppendingPathComponent:[self persistentStoreDataFileName]] retain];
    
    return _persistentStoreDataPath;
}

- (NSString *)persistentStoreDataFileName
{
    if( _persistentStoreDataFileName ) return _persistentStoreDataFileName;
    
    NSString *fileName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
    if( [[self persistentStoreType] isEqualToString:NSSQLiteStoreType] )
        fileName = [fileName stringByAppendingPathExtension:@"sqlite"];
#if TARGET_OS_MAC && !(TARGET_OS_IPHONE)
    else if( [[self persistentStoreType] isEqualToString:NSXMLStoreType] )
        fileName = [fileName stringByAppendingPathExtension:@"xml"];
#endif
    _persistentStoreDataFileName = [fileName retain];
    
    return _persistentStoreDataFileName;
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

+ (id)coreDataFactory
{
    return [[[self alloc] init] autorelease];
}

- (void)dealloc
{
    [_managedObjectContext release];
    [_persistentStoreCoordinator release];
    [_managedObjectModel release];
    
    [_persistentStoreDataFileName release];
    [_persistentStoreDataPath release];
    
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

@synthesize persistentStoreDataFileName = _persistentStoreDataFileName;
@synthesize persistentStoreDataPath = _persistentStoreDataPath;

@synthesize persistentStoreType = _persistentStoreType;
@synthesize persistentStoreOptions = _persistentStoreOptions;

@synthesize mostRecentError = _mostRecentError;

@end
