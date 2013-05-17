//
//  SSAppDelegate.m
//  salesucre
//
//  Created by Haitham Reda on 5/17/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import "SSAppDelegate.h"
#import <CoreData/CoreData.h>
#import "SSIncrementalStore.h"

//---- 3rd Party ---- //
#import <Parse/Parse.h>
#import <iRate.h>
#import "AFNetworkActivityIndicatorManager.h"

@implementation SSAppDelegate

@synthesize window;
@synthesize appStoryBoard = _appStoryBoard;

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;


void uncaughtExceptionHandler(NSException *exception) {
    [Flurry logError:@"Uncaught" message:@"Crash!" exception:exception];
}

+ (void)initialize
{
    //overriding the default iRate strings
    [iRate sharedInstance].applicationBundleID = @"com.olit.salesucre";
    [iRate sharedInstance].appStoreID = [kAppStoreID integerValue];
    [iRate sharedInstance].daysUntilPrompt = 5;
    [iRate sharedInstance].usesUntilPrompt = 2;
    
    [iRate sharedInstance].messageTitle = @"Rate The App";
    [iRate sharedInstance].message = @"We would appreciate if you rate us on the App Store!";
    [iRate sharedInstance].cancelButtonLabel = @"No, Thanks";
    [iRate sharedInstance].remindButtonLabel = @"Remind Me Later";
    [iRate sharedInstance].rateButtonLabel = @"Rate It Now";
#ifdef DEBUG
    [iRate sharedInstance].previewMode  = YES;
#else
    [iRate sharedInstance].previewMode  = NO;
#endif
    
}

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //--- Start Logger --//
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    
    
    // ---- Flurry ---- //
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [Flurry setSessionReportsOnCloseEnabled:NO];
    [Flurry startSession:kFlurryAPIKey];
    [Flurry setSessionReportsOnPauseEnabled:YES];
    
    // ---- ParseSDK ---- //
    [Parse setApplicationId:kParseAppId clientKey:kParseClientKey];
    //[PFUser enableAutomaticUser];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];

    [[PFInstallation currentInstallation] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error)
            DDLogInfo(@"PFInstallation Saved");
        else
            DDLogError(@"PFINstallation could not be saved: %@", [error description]);
    }];
    
    if ([PFUser currentUser] && [[PFUser currentUser] isAuthenticated])
    {
        //[[PFUser currentUser] setObject:[[PFInstallation currentInstallation] installationId] forKey:@"installationId"];
        DDLogInfo(@"#user is authenticated");
    }
    else
    {
        [PFAnonymousUtils logInWithBlock:^(PFUser *user, NSError *error) {
            if (error) {
                DDLogInfo(@"Anonymous login failed: %@", [error description]);
            } else {
                DDLogInfo(@"Anonymous user logged in.");
            }
        }];
        DDLogError(@"[PFUser currentUser] is nil");
    }
    
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound];
#ifdef DEBUG
    [Parse errorMessagesEnabled:YES];
#endif
    
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:8 * 1024 * 1024 diskCapacity:20 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    
    
    
    
//    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
//    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - App Init
- (void)loadApplication
{
    if(_appStoryBoard){
        _appStoryBoard  = nil;
    }
    
    splashView = [[XCSplashViewController alloc] initWithNibName:@"XCSplashViewController" bundle:[NSBundle mainBundle]];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:splashView];
    [self.window makeKeyAndVisible];
    
    DDLogInfo(@"SplashView Added");
    
    
    //check if firstRun
    int firstRun = [[NSUserDefaults standardUserDefaults] integerForKey:@"firstRun"];
    DDLogInfo(@"first run %d", firstRun);
    if( (!firstRun) || (firstRun != 1))
    {
        
        [self performSelector:@selector(detectLanguage)];
        
    }else{
        
        language_ = @"en";//[[NSUserDefaults standardUserDefaults] stringForKey:@"language"];
        [self performSelector:@selector(startApplicationWithLanguage:) withObject:language_ afterDelay:2.0];
    }
}

#pragma mark - Core Data

- (void)saveContext {
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext {
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        __managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    
    return __managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil) {
        return __managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:kDataModelStoreName withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return __managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (__persistentStoreCoordinator != nil) {
        return __persistentStoreCoordinator;
    }
    
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    AFIncrementalStore *incrementalStore = (AFIncrementalStore *)[__persistentStoreCoordinator addPersistentStoreWithType:[SSIncrementalStore type] configuration:nil URL:nil options:nil error:nil];
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"salesucre.sqlite"];
    
    NSDictionary *options = @{
                              NSInferMappingModelAutomaticallyOption : @(YES),
                              NSMigratePersistentStoresAutomaticallyOption: @(YES)
                              };
    
    NSError *error = nil;
    if (![incrementalStore.backingPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    NSLog(@"SQLite URL: %@", storeURL);
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
