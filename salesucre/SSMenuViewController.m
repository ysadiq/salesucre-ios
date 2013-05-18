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
    
    [self setTitle:@"Menu"];
    
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
    //    NSPredicate *p = [NSPredicate predicateWithFormat:@"categoryName LIKE 'Fashion'"];
    //    [fetchRequest setPredicate:p];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc]
                                 initWithFetchRequest:fetchRequest managedObjectContext:[(id)[[UIApplication sharedApplication] delegate] managedObjectContext]
                                 sectionNameKeyPath:nil cacheName:@"SSCategory"];
    
    _fetchedResultsController.delegate = self;
    [self refetchData];
    
    
    [self.tableView registerClass:[SSCell class] forCellReuseIdentifier:@"SSCell"];
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
        [cell setCateforiesData:(SSCategory *)[_fetchedResultsController objectAtIndexPath:indexPath] withLanguage:@"en"];
    }
    @catch (NSException *exception) {
        DDLogError(@"Exception: %@", exception);
    }
    
    return cell;
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

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    [self.tableView reloadData];
}

@end
