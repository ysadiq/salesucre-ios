//
//  SSProductListViewController.m
//  salesucre
//
//  Created by Haitham Reda on 5/18/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import "SSProductListViewController.h"
#import "SSCell.h"
#import "SSProductDetailsViewController.h"

@interface SSProductListViewController () <NSFetchedResultsControllerDelegate> {

NSFetchedResultsController *_fetchedResultsController;

}
- (void)refetchData;
@end

@implementation SSProductListViewController

@synthesize tableView = _tableView;
@synthesize currentcategory = _currentcategory;
@synthesize productToPass = _productToPass;

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
    DDLogInfo(@"products did load");
    [self.view setBackgroundColor:[UIColor clearColor]];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    //language
    //    language_ = [[NSUserDefaults standardUserDefaults] stringForKey:@"language"];
    //    NSString* path= [[NSBundle mainBundle] pathForResource:language_ ofType:@"lproj"];
    //    NSBundle* languageBundle_ = [NSBundle bundleWithPath:path];
    
    //---- title ---- //
    [self setTitle:[_currentcategory name]];
    
    //---- AFIncrementalStore ---- //
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SSMenuItem"];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"weight" ascending:NO]];
    fetchRequest.fetchLimit = 100;
    
    //---- NSPredicate ---- //
    DDLogInfo(@"currentCategory: %@", [_currentcategory categoryId]);
    NSPredicate *p = [NSPredicate predicateWithFormat:@"ANY categories.categoryId = %@ AND deletedAt = nil", [_currentcategory categoryId] ];
    [fetchRequest setPredicate:p];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc]
                                 initWithFetchRequest:fetchRequest managedObjectContext:[(id)[[UIApplication sharedApplication] delegate] managedObjectContext]
                                 sectionNameKeyPath:nil cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    [self refetchData];
    
    if (kiOS6)
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
    
//    for (SSMenuItem *child in _fetchedResultsController.fetchedObjects )
//    {
//        DDLogError(@"Data: %@", child.name);
//        DDLogError(@"Data: %@", child.itemId);
//    }
    
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    // cell setOutletsData
    //[cell setCategoriesData:[dataCache_ valueForKey:[dataCacheKeys_ objectAtIndex:indexPath.row]] withLanguage:language_];
    
    @try {
        
        [cell setMenuItem:[_fetchedResultsController objectAtIndexPath:indexPath]];
    }
    @catch (NSException *exception) {
        DDLogError(@"method: %s, line: %i", __PRETTY_FUNCTION__, __LINE__);
        DDLogError(@"Exception: %@", exception);
        for (SSMenuItem *child in _fetchedResultsController.fetchedObjects )
        {
            DDLogError(@"Data: %@", child.name);
        }
    }
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    SSMenuItem *updatedItem = [_fetchedResultsController objectAtIndexPath:indexPath];
    [(SSCell *)cell setMenuItem:updatedItem];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SSMenuItem *item = (SSMenuItem *)[_fetchedResultsController objectAtIndexPath:indexPath];
    DDLogInfo(@"current price: %i", [[item price] intValue]);
    _productToPass = (SSMenuItem *)[_fetchedResultsController objectAtIndexPath:indexPath];
    
    [self setHidesBottomBarWhenPushed:YES];
    [self performSegueWithIdentifier:@"002" sender:self];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"002"])
    {
        SSProductDetailsViewController *vc = [segue destinationViewController];
        [vc setSelectedItem:_productToPass];
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
    
    DDLogInfo(@"#content changed, count: %i", [_fetchedResultsController.fetchedObjects count]);
    for (SSMenuItem *item in _fetchedResultsController.fetchedObjects)
    {
        DDLogError(@"item %@", item.name);
    }
    
    [self.tableView endUpdates];
    //[self.tableView reloadData];
}

- (void)newLastModifiedValue
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SSMenuItem"
                                              inManagedObjectContext:[_fetchedResultsController managedObjectContext]];
    [fetchRequest setEntity:entity];
    [fetchRequest setFetchLimit:100];
    //[fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:@"lastModified"]];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                        initWithKey:@"lastModified"
                                        ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    NSArray *fetchResults = [[_fetchedResultsController managedObjectContext]
                             executeFetchRequest:fetchRequest
                             error:&error];
    
    SSMenuItem *oldest = [fetchResults lastObject];
    
    DDLogInfo(@"before reloading table, max lastModified is :%@", [oldest lastModified]);
}

@end
