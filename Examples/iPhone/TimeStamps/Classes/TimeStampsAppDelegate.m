#import "TimeStampsAppDelegate.h"
#import "RootViewController.h"
#import "TICoreDataFactory.h"

@implementation TimeStampsAppDelegate

#pragma mark -
#pragma mark Application Lifecycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    TICoreDataFactory *factory = [TICoreDataFactory coreDataFactory];
    [[self rootViewController] setManagedObjectContext:[factory managedObjectContext]];
	
    [[self window] addSubview:[[self navigationController] view]];
    [[self window] makeKeyAndVisible];
	return YES;
}

#pragma mark -
#pragma mark Initialization and Deallocation
- (void)dealloc
{
    [_rootViewController release];
	[_navigationController release];
	[_window release];
    
	[super dealloc];
}

#pragma mark -
#pragma mark Properties
@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize rootViewController = _rootViewController;

@end

