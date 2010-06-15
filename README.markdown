#TICoreDataUtilities
*Utilities to make Core Data applications as free of template code (and as painless) as possible*  

Tim Isted  
[http://www.timisted.net](http://www.timisted.net)  
Twitter: @[timisted](http://twitter.com/timisted)

##License
TICoreDataUtilities is offered under the **MIT** license.

##Summary
`TICoreDataUtilities` is a collection of classes (well, currently one class, I'm not ready to release the rest yet) to make it easier to work with Core Data, or replace much of the template code in Core Data application projects both on the Mac desktop and on iPhone OS/iOS. Functionality includes

* Easy creation of a Managed Object Context (MOC), with auto-generation of Persistent Store Coordinator, Managed Object Model merged from bundles, etc, using just one line of code.

##Basic Usage
Copy all the files in the `TICoreDataUtilities` directory into your project.

The only utility available at the moment is `TIManagedObjectContextProvider`.

There's no need to start with the Core Data project templates provided with Xcode, just use a suitable Mac/iPhone OS/iOS application template, add `CoreData.framework`, along with a suitable data model file or bundle, and `#include <CoreData/CoreData.h>` in any files referring to Core Data objects like `NSManagedObjectContext`.

###Creating a Managed Object Context
To create a pre-configured managed object context, with persistent store coordinator etc, set to migrate stores automatically, create an instance of the provider and ask it for a managed object context: 

    TIManagedObjectContextProvider *provider = [TIManagedObjectContextProvider managedObjectContextProvider];
    NSManagedObjectContext *context = [provider managedObjectContext];

The `managedObjectContext` method will build the underlying Core Data objects, if necessary, from the ground up:

* A persistent store co-ordinator will be created, using some default settings, all of which may be overridden:
  * `storeDataFileName`: the name of the persistent store file on disk. By default, this will be the name of the application, with ".sqlite" appended if it's a SQLite store type, or ".xml" for XML stores.
  * `storeDataFilePath`: the path to the persistent store file on disk. By default, this will take `storeDataFileName` and append it to the application's documents directory on the iPhone, or `~/Library/Application Support/AppName` on the desktop (creating the directory if necessary).
  * `persistentStoreType`: the type of file to use. By default, this uses `NSSQLiteStoreType`.
  * `persistentStoreOptions`: a dictionary of options specified when the persistent store is created. By default, the only option is `NSMigratePersistentStoresAutomaticallyOption` set to `1`.
* The managed object model object used by default is created using `mergedModelFromBundles:nil`. If you want to specify a different model object, just set the `managedObjectModel` property on the `TIManagedObjectContextProvider` object *before* calling `managedObjectContext`.

###Creating Secondary Contexts
If you `retain` the provider object, you can use it to create secondary contexts for use with e.g. background import operations, like this:

    NSManagedObjectContext *secondaryContext = [provider secondaryManagedObjectContext];

The `secondaryManagedObjectContext` method returns a new, `autoreleased` managed object context, with the same persistent store coordinator used by the primary context.

##To Do List
* Merge `TIManagedObjectExtensions` into `TICoreDataUtilities`.