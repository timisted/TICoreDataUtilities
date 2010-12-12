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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol TIUITableViewCoreDataProviderDelegate;

@interface TIUITableViewCoreDataProvider : NSObject <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate> {
    __weak NSObject <TIUITableViewCoreDataProviderDelegate> *_delegate;
    NSError *_mostRecentError;
    
    NSManagedObjectContext *_managedObjectContext;
    
    NSFetchedResultsController *_fetchedResultsController;    
    NSFetchRequest *_fetchRequest;
    NSString *_sectionNameKeyPath;
    NSString *_cacheName;
    
    NSString *_entityName;
    NSArray *_sortDescriptors;
    NSPredicate *_fetchPredicate;
    
    NSString *_displayAttributeName;
    UITableView *_tableViewToUpdate;
    BOOL _reloadsEntireTableViewForAnyChange;
    
    BOOL _saveContextAfterEditing;
}

- (id)initWithFetchRequest:(NSFetchRequest *)aFetchRequest managedObjectContext:(NSManagedObjectContext *)aMoc;
- (id)initWithEntityName:(NSString *)anEntityName displayAttributeName:(NSString *)anAttributeName managedObjectContext:(NSManagedObjectContext *)aMoc;

- (void)configureForAndSetAsDataSourceAndDelegateToTableView:(UITableView *)aTableView;
- (void)performFetch;
- (void)performFetchAndReloadTableView;

@property (nonatomic, assign) __weak NSObject <TIUITableViewCoreDataProviderDelegate> *delegate;
@property (nonatomic, retain) NSError *mostRecentError;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) NSFetchRequest *fetchRequest;
@property (nonatomic, retain) NSString *sectionNameKeyPath;
@property (nonatomic, retain) NSString *cacheName;

@property (nonatomic, retain) NSString *entityName;
@property (nonatomic, retain) NSArray *sortDescriptors;
@property (nonatomic, retain) NSPredicate *fetchPredicate;

@property (nonatomic, retain) NSString *displayAttributeName;
@property (nonatomic, retain) UITableView *tableViewToUpdate;
@property (nonatomic, assign) BOOL reloadsEntireTableViewForAnyChange;

@property (nonatomic, assign) BOOL saveContextAfterEditing;

@end


@protocol TIUITableViewCoreDataProviderDelegate

@optional
- (void)tableViewCoreDataProvider:(TIUITableViewCoreDataProvider *)aProvider encounteredError:(NSError *)anError;
- (void)tableViewCoreDataProvider:(TIUITableViewCoreDataProvider *)aProvider configureCell:(UITableViewCell *)aCell forObject:(NSManagedObject *)anObject;
- (BOOL)tableViewCoreDataProvider:(TIUITableViewCoreDataProvider *)aProvider shouldDeleteObject:(NSManagedObject *)anObject;
- (BOOL)tableViewCoreDataProvider:(TIUITableViewCoreDataProvider *)aProvider canEditRowForObject:(NSManagedObject *)anObject;
- (void)tableViewCoreDataProvider:(TIUITableViewCoreDataProvider *)aProvider objectWasSelected:(NSManagedObject *)anObject;
- (BOOL)tableViewCoreDataProvider:(TIUITableViewCoreDataProvider *)aProvider shouldSelectObject:(NSManagedObject *)anObject;

@end