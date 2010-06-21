#import "RootViewController.h"


@implementation RootViewController

#pragma mark -
#pragma mark View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
    [[self navigationItem] setRightBarButtonItem:addButton];
    [addButton release];
    
    [[self tableViewDataProvider] configureForAndSetAsDataSourceAndDelegateToTableView:[self tableView]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self tableViewDataProvider] performFetchAndReloadTableView];
}

#pragma mark -
#pragma mark Adding New Items
- (void)addItem:(id)sender
{
    NSManagedObject *newObject = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:[self managedObjectContext]];
    [newObject setValue:[NSDate date] forKey:@"timeStamp"];
    
    NSError *error = nil;
    BOOL success = [[self managedObjectContext] save:&error];
    if( !success ) NSLog(@"Error saving: %@", error);
}

#pragma mark -
#pragma mark Data Provider Delegate Methods
- (void)tableViewCoreDataProvider:(TIUITableViewCoreDataProvider *)aProvider objectWasSelected:(NSManagedObject *)anObject
{
    NSLog(@"Selected object = %@", anObject);
}

- (void)tableViewCoreDataProvider:(TIUITableViewCoreDataProvider *)aProvider encounteredError:(NSError *)anError
{
    NSLog(@"An error occurred = %@", anError);
}

#pragma mark -
#pragma mark Lazy Accessors
- (TIUITableViewCoreDataProvider *)tableViewDataProvider
{
    if( _tableViewDataProvider ) return _tableViewDataProvider;
    
    _tableViewDataProvider = [[TIUITableViewCoreDataProvider alloc] initWithEntityName:@"Event" displayAttributeName:@"timeStamp" managedObjectContext:[self managedObjectContext]];
    [_tableViewDataProvider setDelegate:self];
    
    return _tableViewDataProvider;
}

#pragma mark -
#pragma mark Initialization and Deallocation
- (void)dealloc
{
    [_managedObjectContext release];
    [_tableViewDataProvider release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Properties
@synthesize managedObjectContext = _managedObjectContext;
@synthesize tableViewDataProvider = _tableViewDataProvider;

@end

