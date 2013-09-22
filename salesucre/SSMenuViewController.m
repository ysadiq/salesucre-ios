//
//  SSMenuViewController.m
//  salesucre
//
//  Created by Haitham Reda on 5/17/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import "SSMenuViewController.h"
#import "SSCell.h"
#import "SSProductListViewController.h"

@interface SSMenuViewController () <NSFetchedResultsControllerDelegate> {
    
    NSFetchedResultsController *_fetchedResultsController;
}

- (void)refetchData;
@end

@implementation SSMenuViewController

@synthesize tableView;
@synthesize objectToSend;
@synthesize isLegacyiOS;

- (void)refetchData
{
    [_fetchedResultsController performSelectorOnMainThread:@selector(performFetch:) withObject:nil waitUntilDone:YES modes:@[ NSRunLoopCommonModes ]];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    DDLogInfo(@"menu did load");
    
    if (kiOS7OrMore)
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(kiOS6))
    {
        self.isLegacyiOS = NO;
    }
    else
    {
        self.isLegacyiOS = YES;
    }
    
    [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:THEME_TABBAR_MENU_ICON_SELECTED]
                  withFinishedUnselectedImage:[UIImage imageNamed:THEME_TABBAR_MENU_ICON_UNSELECTED]];
    
    // ---- reload ---- //
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refetchData)];
    
    [self setTitle:@"Menu"];
    [self.view setBackgroundColor:[UIColor UIColorFromHex:0xf8f4ed]];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    if (kPriorToiOS7)
    {
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:THEME_TABBAR_MENU_ICON_SELECTED]
                      withFinishedUnselectedImage:[UIImage imageNamed:THEME_TABBAR_MENU_ICON_UNSELECTED] ];
    }
    else
    {
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"menu-icon-selected-ios7"]
                    withFinishedUnselectedImage:[UIImage imageNamed:@"menu-icon-unselected-ios7"] ];
    }
    
    //language
//    language_ = [[NSUserDefaults standardUserDefaults] stringForKey:@"language"];
//    NSString* path= [[NSBundle mainBundle] pathForResource:language_ ofType:@"lproj"];
//    NSBundle* languageBundle_ = [NSBundle bundleWithPath:path];
    
    //[self performSelector:@selector(fetchCategoriesAvailableFromServer)];
    
    //---- AFIncrementalStore ---- //
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SSCategory"];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"weight" ascending:NO]];
    fetchRequest.fetchLimit = 100;
    
    //---- NSPredicate ---- //
    NSPredicate *p = [NSPredicate predicateWithFormat:@"deletedAt = nil"];
    [fetchRequest setPredicate:p];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc]
                                 initWithFetchRequest:fetchRequest managedObjectContext:[(id)[[UIApplication sharedApplication] delegate] managedObjectContext]
                                 sectionNameKeyPath:nil cacheName:@"SSCategory"];
    
    _fetchedResultsController.delegate = self;
    [self refetchData];
    
    if (!isLegacyiOS)
    {
        [self.tableView registerClass:[SSCell class] forCellReuseIdentifier:@"SSCell"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //return 0;
    DDLogError(@"number of rows: %i", [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects]);
    return [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //return 0;
    return [[_fetchedResultsController sections] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [kDefaultCellHeight floatValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SSCell";
    
    SSCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        if (self.isLegacyiOS)
        {
            cell = [[SSCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    @try {
        [cell setCateforiesData:(SSCategory *)[_fetchedResultsController objectAtIndexPath:indexPath] withLanguage:@"en"];
    }
    @catch (NSException *exception) {
        DDLogError(@"method: %s, line: %i", __PRETTY_FUNCTION__, __LINE__);
        DDLogError(@"Exception: %@", exception);
    }
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    SSCategory *updatedCategory = [_fetchedResultsController objectAtIndexPath:indexPath];
//    if ([updatedCategory deletedAt])
//    {
//        DDLogWarn(@"#deletedAt category detected, deleting now: %@", updatedCategory.name);
//        NSManagedObjectContext *currentContext = [_fetchedResultsController managedObjectContext];
//        [currentContext deleteObject:updatedCategory];
//        
//        NSError *error;
//        if ([currentContext hasChanges] && ![currentContext save:&error]) {
//            // Replace this implementation with code to handle the error appropriately.
//            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//            abort();
//        }
//        else
//        {
//            DDLogInfo(@"saved with success after deletion");
//        }
//
//    }
    
    [(SSCell *)cell setCateforiesData:updatedCategory withLanguage:@"en"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLogInfo(@"inside didselectrow");
    [self setObjectToSend:[_fetchedResultsController objectAtIndexPath:indexPath] ];
    
    [self performSegueWithIdentifier:@"001" sender:self];
}

#pragma mark - Storyboard
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"001"]) {
        DDLogCVerbose(@"preparing segue");
        SSProductListViewController *destinationVC = [segue destinationViewController];
        [destinationVC setCurrentcategory:[self objectToSend]];
    }
}

#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)object
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] forRowAtIndexPath:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    DDLogInfo(@"tableview endUpdates");
    [self.tableView endUpdates];
    //[self.tableView reloadData];
}


@end
