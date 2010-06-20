// Copyright (c) 2010 Tim Isted
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "TIUITableViewCoreDataProvider.h"


@interface TIUITableViewCoreDataProvider ()

- (void)_notifyDelegateAndSetError:(NSError *)anError;
- (BOOL)_delegateWasAskedToConfigureCell:(UITableViewCell *)aCell forObject:(NSManagedObject *)anObject;
- (BOOL)_askDelegateWhetherWeShouldDeleteObject:(NSManagedObject *)anObject;
- (BOOL)_askDelegateWhetherWeCanEditRowForObject:(NSManagedObject *)anObject;
- (BOOL)_askDelegateWhetherWeShouldSelectAnObject:(NSManagedObject *)anObject;
- (void)_notifyDelegateThatObjectWasSelected:(NSManagedObject *)anObject;

- (void)_configureCell:(UITableViewCell *)aCell forObject:(NSManagedObject *)anObject;

@end


@implementation TIUITableViewCoreDataProvider

#pragma mark -
#pragma mark Delegate Communications
- (void)_notifyDelegateAndSetError:(NSError *)anError
{
    [self setMostRecentError:anError];
    
    if( ![[self delegate] respondsToSelector:@selector(tableViewCoreDataProvider:encounteredError:)] ) 
        return;
    
    [[self delegate] tableViewCoreDataProvider:self encounteredError:anError];
}

- (BOOL)_delegateWasAskedToConfigureCell:(UITableViewCell *)aCell forObject:(NSManagedObject *)anObject
{
    if( ![[self delegate] respondsToSelector:@selector(tableViewCoreDataProvider:configureCell:forObject:)] )
        return NO;
    
    [[self delegate] tableViewCoreDataProvider:self configureCell:aCell forObject:anObject];
    return YES;
}

- (BOOL)_askDelegateWhetherWeShouldDeleteObject:(NSManagedObject *)anObject
{
    if( ![[self delegate] respondsToSelector:@selector(tableViewCoreDataProvider:shouldDeleteObject:)] )
        return YES;
    
    return [[self delegate] tableViewCoreDataProvider:self shouldDeleteObject:anObject];
}

- (BOOL)_askDelegateWhetherWeCanEditRowForObject:(NSManagedObject *)anObject
{
    if( ![[self delegate] respondsToSelector:@selector(tableViewCoreDataProvider:canEditRowForObject:)] )
        return YES;
    
    return [[self delegate] tableViewCoreDataProvider:self canEditRowForObject:anObject];
}

- (BOOL)_askDelegateWhetherWeShouldSelectAnObject:(NSManagedObject *)anObject
{
    if( ![[self delegate] respondsToSelector:@selector(tableViewCoreDataProvider:shouldSelectObject:)] )
        return YES;
    
    return [[self delegate] tableViewCoreDataProvider:self shouldSelectObject:anObject];
}

- (void)_notifyDelegateThatObjectWasSelected:(NSManagedObject *)anObject
{
    if( ![[self delegate] respondsToSelector:@selector(tableViewCoreDataProvider:objectWasSelected:)] )
        return;
    
    [[self delegate] tableViewCoreDataProvider:self objectWasSelected:anObject];
}

#pragma mark -
#pragma mark Fetching
- (void)performFetch
{
    NSError *error = nil;
    BOOL success = [[self fetchedResultsController] performFetch:&error];
    if( !success ) [self _notifyDelegateAndSetError:error];
}

- (void)performFetchAndReloadTableView
{
    [self performFetch];
    
    [[self tableViewToUpdate] reloadData];
}

#pragma mark -
#pragma mark Fetched Results Controller 
- (NSFetchedResultsController *)fetchedResultsController
{
    if( _fetchedResultsController ) return _fetchedResultsController;
    
    if( ![self fetchRequest] || ![self managedObjectContext] || [[[self fetchRequest] sortDescriptors] count] < 1 ) return nil;
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:[self fetchRequest] managedObjectContext:[self managedObjectContext] sectionNameKeyPath:[self sectionNameKeyPath] cacheName:[self cacheName]];
    [_fetchedResultsController setDelegate:self];
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if( [self reloadsEntireTableViewForAnyChange] ) return;
    
    [[self tableViewToUpdate] beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if( [self reloadsEntireTableViewForAnyChange] ) return;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [[self tableViewToUpdate] insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [[self tableViewToUpdate] deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{    
    if( [self reloadsEntireTableViewForAnyChange] ) return;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [[self tableViewToUpdate] insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [[self tableViewToUpdate] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self _configureCell:[[self tableViewToUpdate] cellForRowAtIndexPath:indexPath] forObject:anObject];
            break;
            
        case NSFetchedResultsChangeMove:
            [[self tableViewToUpdate] deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [[self tableViewToUpdate] insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if( [self reloadsEntireTableViewForAnyChange] )
        [[self tableViewToUpdate] reloadData];
    else
        [[self tableViewToUpdate] endUpdates];
}

#pragma mark -
#pragma mark Default Behavior
- (void)_configureCell:(UITableViewCell *)aCell forObject:(NSManagedObject *)anObject
{
    if( [self _delegateWasAskedToConfigureCell:aCell forObject:anObject] ) return;
    
    if( ![self displayAttributeName] ) return;
    
    [[aCell textLabel] setText:[anObject valueForKey:[self displayAttributeName]]];
}

#pragma mark -
#pragma mark Table View Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[self fetchedResultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[[self fetchedResultsController] sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *sCellIdentifier = @"TIUITableViewReusableCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sCellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sCellIdentifier] autorelease];
    }
    
    NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    [self _configureCell:cell forObject:object];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    return [self _askDelegateWhetherWeCanEditRowForObject:object];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        if( ![self _askDelegateWhetherWeShouldDeleteObject:object] ) return;
        
        if( ![self saveContextAfterEditing] ) return;
        
        [[self managedObjectContext] deleteObject:object];
        
        // Save the context.
        NSError *error = nil;
        if( ![[self managedObjectContext] save:&error] ) {
            [self _notifyDelegateAndSetError:error];
        }
    }   
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

#pragma mark -
#pragma mark Table View Delegate
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    if( [self _askDelegateWhetherWeShouldSelectAnObject:object] )
        return indexPath;
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    
    [self _notifyDelegateThatObjectWasSelected:object];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark Lazy Accessors
- (NSFetchRequest *)fetchRequest
{
    if( _fetchRequest ) return _fetchRequest;
    
    if( ![self entityName] ) return nil;
    
    _fetchRequest = [[NSFetchRequest alloc] init];
    [_fetchRequest setEntity:[NSEntityDescription entityForName:[self entityName] inManagedObjectContext:[self managedObjectContext]]];
    
    [_fetchRequest setSortDescriptors:[self sortDescriptors]];
    [_fetchRequest setPredicate:[self fetchPredicate]];
    
    return _fetchRequest;
}

- (NSArray *)sortDescriptors
{
    if( _sortDescriptors ) return _sortDescriptors;
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:[self displayAttributeName] ascending:YES];
    _sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [sortDescriptor release];
    
    return _sortDescriptors;
}

#pragma mark -
#pragma mark Configuration and Setup
- (void)configureForAndSetAsDataSourceAndDelegateToTableView:(UITableView *)aTableView
{
    _tableViewToUpdate = [aTableView retain];
    
    [aTableView setDelegate:self];
    [aTableView setDataSource:self];
}

#pragma mark -
#pragma mark Initialization and Deallocation
- (id)initWithFetchRequest:(NSFetchRequest *)aFetchRequest managedObjectContext:(NSManagedObjectContext *)aMoc
{
    if( [self init] ) {
        _fetchRequest = [aFetchRequest retain];
        _managedObjectContext = [aMoc retain];
    }
    
    return self;
}

- (id)initWithEntityName:(NSString *)anEntityName displayAttributeName:(NSString *)anAttributeName managedObjectContext:(NSManagedObjectContext *)aMoc
{
    if( [self init] ) {
        _entityName = [anEntityName retain];
        _displayAttributeName = [anAttributeName retain];
        _managedObjectContext = [aMoc retain];
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    
    if( self ) {
        _saveContextAfterEditing = YES;
    }
    
    return self;
}

- (void)dealloc
{
    [_mostRecentError release];
    [_managedObjectContext release];
    [_fetchedResultsController release];
    [_fetchRequest release];
    [_sectionNameKeyPath release];
    [_cacheName release];
    
    [_entityName release];
    [_sortDescriptors release];
    
    [_displayAttributeName release];
    [_tableViewToUpdate release];
    
    [super dealloc];
}

#pragma mark -
#pragma mark Properties
@synthesize delegate = _delegate;
@synthesize mostRecentError = _mostRecentError;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize fetchRequest = _fetchRequest;
@synthesize sectionNameKeyPath = _sectionNameKeyPath;
@synthesize cacheName = _cacheName;

@synthesize entityName = _entityName;
@synthesize sortDescriptors = _sortDescriptors;
@synthesize fetchPredicate = _fetchPredicate;

@synthesize displayAttributeName = _displayAttributeName;
@synthesize tableViewToUpdate = _tableViewToUpdate;
@synthesize reloadsEntireTableViewForAnyChange = _reloadsEntireTableViewForAnyChange;

@synthesize saveContextAfterEditing = _saveContextAfterEditing;
@end
