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
    
    //language
    //    language_ = [[NSUserDefaults standardUserDefaults] stringForKey:@"language"];
    //    NSString* path= [[NSBundle mainBundle] pathForResource:language_ ofType:@"lproj"];
    //    NSBundle* languageBundle_ = [NSBundle bundleWithPath:path];
    
    //---- title ---- //
    [self setTitle:[_currentcategory name]];
    
    //---- AFIncrementalStore ---- //
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SSMenuItem"];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"lastModified" ascending:NO]];
    fetchRequest.fetchLimit = 100;
    
    //---- NSPredicate ---- //
    DDLogInfo(@"currentCategory: %@", [_currentcategory categoryId]);
    NSPredicate *p = [NSPredicate predicateWithFormat:@"ANY categories.categoryId == %@ AND deletedAt = nil", [_currentcategory categoryId] ];
    [fetchRequest setPredicate:p];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc]
                                 initWithFetchRequest:fetchRequest managedObjectContext:[(id)[[UIApplication sharedApplication] delegate] managedObjectContext]
                                 sectionNameKeyPath:nil cacheName:@"SSCategory"];
    
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
    return [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //return 0;
    return [[_fetchedResultsController sections] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 77.0f;
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
        DDLogError(@"Exception: %@", exception);
    }
    
    return cell;
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

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    DDLogInfo(@"reloading table");
    //[self newLastModifiedValue];
    [self.tableView reloadData];
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
