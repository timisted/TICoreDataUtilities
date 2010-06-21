#TICoreDataUtilities
*Utilities to make Core Data applications as free of template code (and as painless) as possible*  

Tim Isted  
[http://www.timisted.net](http://www.timisted.net)  
Twitter: @[timisted](http://twitter.com/timisted)

##License
TICoreDataUtilities is offered under the **MIT** license.

##Summary
`TICoreDataUtilities` is a collection of classes (well, currently only **two** classes, I'm not ready to release the rest yet) to make it easier to work with Core Data, or replace much of the template code in Core Data application projects both on the Mac desktop and on iPhone OS/iOS. Functionality includes

* Easy creation of a Managed Object Context (MOC), with auto-generation of Persistent Store Coordinator, Managed Object Model merged from bundles, etc, using just one line of code.
* ***New*** Easy provision of information to a `UITableView` (on iOS; Mac version on its way), customizable through delegate calls, removing the need for table view data source and delegate callbacks in view controllers.

##Basic Usage
Copy all the files in the `TICoreDataUtilities` directory into your project.

The only utilities available at the moment are `TICoreDataFactory` for both Mac and iOS, and `TIUITableViewCoreDataProvider` on iOS.

There's no need to start with the Core Data project templates provided with Xcode, just use a suitable Mac/iPhone OS/iOS application template, add `CoreData.framework`, and create your data model file or bundle.

##Creating a Managed Object Context
To create a pre-configured managed object context, with persistent store coordinator, set to migrate stores automatically, create an instance of the factory and ask it for a managed object context: 

    TICoreDataFactory *factory = [TICoreDataFactory coreDataFactory];
    NSManagedObjectContext *context = [factory managedObjectContext];

The `managedObjectContext` method will build the underlying Core Data objects, if necessary, from the ground up:

* A persistent store coordinator will be created, using some default settings, all of which may be overridden:
  * `persistentStoreDataFileName`: the name of the persistent store file on disk. By default, this will be the name of the application, with ".sqlite" appended if it's a SQLite store type, or ".xml" for XML stores (currently on the desktop only).
  * `persistentStoreDataPath`: the path to the persistent store file on disk. By default, this will take `persistentStoreDataFileName` and append it to the application's documents directory on the iPhone, or `~/Library/Application Support/AppName` on the desktop (creating the directory if necessary).
  * `persistentStoreType`: the type of file to use. By default, this uses `NSSQLiteStoreType`.
  * `persistentStoreOptions`: a dictionary of options specified when the persistent store is created. By default, the only option is `NSMigratePersistentStoresAutomaticallyOption` set to `1`.
* The managed object model object used by default is created using `mergedModelFromBundles:nil`. If you want to specify a different model object, just set the `managedObjectModel` property on the `TICoreDataFactory` object *before* calling `managedObjectContext`.

###Specifying Options
If you need to specify your own options to override the defaults, just set them as properties:

    TICoreDataFactory *factory = [TICoreDataFactory coreDataFactory];
    [factory setPersistentStoreType:NSBinaryStoreType];
    [factory setPersistentStoreDataPath:[@"~/Documents/booYeah" stringByExpandingTildeInPath]];
    NSManagedObjectContext *context = [factory managedObjectContext];

###Dealing with Errors
`TICoreDataFactory` maintains a `mostRecentError` property, which is set as its name implies.

Ideally, you should conform to the `TICoreDataFactoryDelegate` protocol, and implement the method `coreDataFactory:encounteredError:` to be notified whenever an error occurs:

    - (void)applicationDidFinishLaunching:(NSNotification *)aNotification
    {
        TICoreDataFactory *factory = [TICoreDataFactory coreDataFactory];
        [factory setDelegate:self];
        [self setManagedObjectContext:[factory managedObjectContext]];
    }
    
    - (void)coreDataFactory:(TICoreDataFactory *)aFactory encounteredError:(NSError *)anError
    {
        NSLog(@"Error = %@", anError);
    }

###Creating Secondary Contexts
If you `retain` the factory object, you can use it to create secondary contexts for use with e.g. background import operations, like this:

    NSManagedObjectContext *secondaryContext = [factory secondaryManagedObjectContext];

The `secondaryManagedObjectContext` method returns a new, `autoreleased` managed object context, with the same persistent store coordinator used by the primary context.

###Notes
Assuming you start with a standard (non-Core Data) application template, don't forget to tell the managed object context to `save:`!

##Supplying Information to a UITableView
When I'm prototyping an app, or working on something in abstraction, I find I frequently need to supply information to a table view for e.g. navigation, or selection of Core Data managed objects. Much of the code necessary to supply the number of sections/rows, configure individual cells, or update the table ends up being copied and pasted template code. 

To avoid this, `TIUITableViewCoreDataProvider` sets itself as the data source and delegate of a table view, and handles most of the work necessary to display information, handle deletion, etc. It uses an `NSFetchedResultsController`, for which it is also the delegate.

You can either supply a fetch request, or specify an entity name and the name of an attribute to be displayed, and it will handle the rest. By default, it will simply set the `text` of each cell's `textLabel`--if the attribute is an `NSString`, it's used as is, otherwise the provider asks the attribute for its `description`. It's easy to customize cell display, however, by configuring the cell yourself through the use of a delegate callback.

Delegate callbacks are also used to determine whether objects are editable, or should be deleted. Each callback refers to the relevant managed object instance, so you don't have to worry about calling `objectAtIndexPath` etc.

###Default Behavior
You have two options to initialize an instance of `TIUITableViewCoreDataProvider`:

* Create and configure a suitable fetch request.
* Supply the name of an entity and an attribute to be displayed.

####Initialization with a Fetch Request
If you choose to create your own fetch request, make sure it's a suitable fetch request for an `NSFetchedResultsController`.

    NSFetchRequest *request = // some pre-configured fetch request
    NSManagedObjectContext *context = // a MOC from somewhere
    TIUITableViewCoreDataProvider *provider = [[TIUITableViewCoreDataProvider alloc] initWithFetchRequest:request 
                                                                                     managedObjectContext:context];

####Initialization by specifying an Entity and Attribute (with optional predicate)
If your request needs are simple, it's easier to create the provider by specifying the name of the entity, and the name of an attribute to be displayed. The default behavior will then create a fetch request as needed for the given entity *and set it to sort ascending on the attribute*.

    NSManagedObjectContext *context = // a MOC from somewhere
    TIUITableViewCoreDataProvider *provider = [[TIUITableViewCoreDataProvider alloc] initWithEntityName:@"MyEntity" 
                                                                                   displayAttributeName:@"someAttribute"
                                                                                   managedObjectContext:context];

If you need to specify a fetch predicate, set it as a property on the provider:

    [provider setFetchPredicate:[NSPredicate predicateWithFormat:...]];

###Configuring the Provider Object for your Table View
Once you've created a `TIUITableViewCoreDataProvider` object, you'll need to configure it:

    [provider configureForAndSetAsDataSourceAndDelegateToTableView:aTableView];

This method also sets the supplied table view's data source and delegate to the data provider object.

###Performing a Fetch
Before the provider can provide any results to a table view, you must call the `performFetch` method.

For convenience, the provider also offers a `performFetchAndReloadTableView` method, which does exactly what it says.

###Configuring Cell Display
The default behavior sets the `text` of each cell's `textLabel`, calling `valueForKey:` on the relevant managed object, and passing it the string set in `displayAttributeName`. If you didn't create the provider object using `initWithEntityName:displayAttributeName:managedObjectContext:`, you'll need to set this `displayAttributeName` property separately.

To customize this behavior, implement the delegate method `tableViewCoreDataProvider:configureCell:forObject:`:

        // set the delegate for the provider
        [provider setDelegate:self];
    }
    
    - (void)tableViewCoreDataProvider:(TIUITableViewCoreDataProvider *)aProvider configureCell:(UITableViewCell *)aCell forObject:(NSManagedObject *)anObject
    {
        [[aCell textLabel] setText:@"Wooooo!"];
        [[aCell detailTextLabel] setText:[anObject valueForKey:@"myAmazinglyInterestingKey"]];
    }

###Allowing Editing (currently only deletion) of Objects
By default, the provider will allow any row in the table view to be edited. To customize this behavior, implement `tableViewCoreDataProvider:canEditRowForObject:`:

    - (BOOL)tableViewCoreDataProvider:(TIUITableViewCoreDataProvider *)aProvider canEditRowForObject:(NSManagedObject *)anObject
    {
        return NO;
    }

If the user deletes a row, the default behavior is to delete the relevant object from the managed object context. To customize this, implement `tableViewCoreDataProvider:shouldDeleteObject:`.

Once any edits (i.e. deletion of objects) have been made, the default behavior is to tell the managed object context to `save:`. To override this, set the `saveContextAfterEditing` property on the provider object to `NO`.

###Selection of Objects
When the user taps a row in the interface, the default behavior is to allow selection, then immediately deselect the row (with animation). Implement the `tableViewCoreDataProvider:objectWasSelected:` method to do whatever you need to do when an object is selected. At present there is no way to prevent a row from being automatically **de**selected.

To prevent the user from being able to select a row for some object, implement `tableViewCoreDataProvider:shouldSelectObject:`.

###Dealing with Errors
`TIUITableViewCoreDataProvider` maintains a `mostRecentError` property, which is set as its name implies.

Implement the delegate method `tableViewCoreDataProvider:encounteredError:` to be informed of any errors as they occur.

###Fetched Results Controller settings
To take advantage of the automatic section capabilities in `NSFetchedResultsController`, set the `sectionNameKeyPath` property on the provider object. The fetched results controller object is created lazily, so the `sectionNameKeyPath` property needs to be set before the provider object is asked for information by the table view. Note that if you specify a section name key path, `NSFetchedResultsController` requires you to provide suitable sort descriptors.

By default, the provider doesn't use a cache for the fetched results controller. Set the `cacheName` property to specify a cache.

The provider object will respond to `NSFetchedResultsControllerDelegate` methods to make automatic updates to the table view on a row-by-row basis. If you would prefer just to reload the table view whenever changes occur, set the `reloadsEntireTableViewForAnyChange` property to `YES`.

##Example Projects
A Mac example project is on its way.

###iPhone - TimeStamps
There is one example iPhone project included, which mimics the behavior of the default Core Data iPhone Navigation-Based template project with an `Event` entity and `timeStamp` attribute. 

The application delegate uses `TICoreDataFactory` to generate the Core Data stack, including the managed object context, which it passes to the root view controller at launch. The view controller implements `tableViewCoreDataProvider:objectWasSelected:` to log a message to the console whenever the user selects a row.

Note that the example project saves the managed object context whenever new objects are added, and uses the default bevahior of the provider object to save the context whenever objects are deleted, so there's no need for the app delegate to `save:` the context at termination. 

##To Do List
* Add `TINSTableViewCoreDataProvider` class.
* Merge `TIManagedObjectExtensions` into `TICoreDataUtilities`.