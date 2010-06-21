@class RootViewController;

@interface TimeStampsAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *_window;
    UINavigationController *_navigationController;
    RootViewController *_rootViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;

@end

