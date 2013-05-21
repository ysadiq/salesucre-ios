//
//  SSBranchesViewController.m
//  salesucre
//
//  Created by Haitham Reda on 5/19/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import "SSBranchesViewController.h"
#import "SSCell.h"
#import "SSBranchDetailsViewController.h"

@interface SSBranchesViewController () <NSFetchedResultsControllerDelegate> {
    
    NSFetchedResultsController *_fetchedResultsController;
    
}
- (void)refetchData;
@end


@implementation SSBranchesViewController

@synthesize tableView;
@synthesize branchToPass = _branchToPass;

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
    
    [self setTitle:@"Branches"];
    
    //---- AFIncrementalStore ---- //
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Branch"];
    
    NSSortDescriptor *sCity = [[NSSortDescriptor alloc] initWithKey:@"cityWeight" ascending:NO];
    NSSortDescriptor *sDistrict = [[NSSortDescriptor alloc] initWithKey:@"districtWeight" ascending:NO];
    
    fetchRequest.sortDescriptors = [NSArray arrayWithObjects:sCity,sDistrict,nil];
    fetchRequest.fetchLimit = 100;
    
    //---- NSPredicate ---- //
//    NSPredicate *p = [NSPredicate predicateWithFormat:@"ANY categories.categoryId == %@", [_currentcategory categoryId] ];
//    [fetchRequest setPredicate:p];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc]
                                 initWithFetchRequest:fetchRequest managedObjectContext:[(id)[[UIApplication sharedApplication] delegate] managedObjectContext]
                                 sectionNameKeyPath:@"cityName" cacheName:@"Branch"];
    
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
        [cell setBranchDetails:[_fetchedResultsController objectAtIndexPath:indexPath]];
    }
    @catch (NSException *exception) {
        DDLogError(@"Exception: %@", exception);
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Branch *branch = (Branch *)[_fetchedResultsController objectAtIndexPath:indexPath];
    DDLogInfo(@"current name: %@", [branch branchId]);
    [self setBranchToPass: (Branch *)[_fetchedResultsController objectAtIndexPath:indexPath] ];
}

#pragma mark - Tableview headers
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 32.0f)];
    [title setFont:[UIFont boldSystemFontOfSize:18] ];
    [title setTextAlignment:NSTextAlignmentCenter];
    [title setTextColor:[UIColor whiteColor]];
    [title setBackgroundColor:[UIColor clearColor]];
    [title setText:[[[_fetchedResultsController sections] objectAtIndex:section] name] ];
    
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 32.0f)];
    [header setBackgroundColor:[UIColor brownColor]];
    
    [header addSubview:title];
    
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 32.0;
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"011"])
    {
#warning put some code here
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Branch"
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
