#import "TIUITableViewCoreDataProvider.h"

@interface RootViewController : UITableViewController <TIUITableViewCoreDataProviderDelegate> {
    NSManagedObjectContext *_managedObjectContext;
    TIUITableViewCoreDataProvider *_tableViewDataProvider;
}

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) TIUITableViewCoreDataProvider *tableViewDataProvider;

@end
