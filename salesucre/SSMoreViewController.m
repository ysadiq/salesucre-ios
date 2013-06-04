//
//  SSMoreViewController.m
//  salesucre
//
//  Created by Yahia on 6/3/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import "SSMoreViewController.h"
#import "MGScrollView.h"
#import "MGTableBoxStyled.h"
#import "MGLineStyled.h"
#import "UIViewController+MJPopupViewController.h"
#import "SSPopupViewController.h"
#import "SSContacts.h"

//@interface SSMoreViewController (){
//    MGBox *photosGrid, *tablesGrid, *table1, *table2;
//    UIImage *arrow, *call;
//    UIFont *currentFont;
//}
//@end

@interface SSMoreViewController () <NSFetchedResultsControllerDelegate> {
    
    NSFetchedResultsController *_fetchedResultsController;
    MGBox *photosGrid, *tablesGrid, *table1, *table2;
    UIImage *arrow, *call;
    UIFont *currentFont;
}

- (void)refetchData;
@end

#define ROW_SIZE               (CGSize){304, 44}
#define IPHONE_PORTRAIT_GRID   (CGSize){312, 0}
#define IPHONE_LANDSCAPE_GRID  (CGSize){160, 0}
#define IPHONE_TABLES_GRID     (CGSize){320, 0}

#define HEADER_FONT            [UIFont fontWithName:@"HelveticaNeue" size:18]

@implementation SSMoreViewController

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
    
    [self setTitle:@"More"];
    [self.view setBackgroundColor:[UIColor UIColorFromHex:0xf8f4ed]];
    
    //---- AFIncrementalStore ---- //
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SSContacts"];
    fetchRequest.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"lastModified" ascending:NO]];
    fetchRequest.fetchLimit = 5;
    
    //---- NSPredicate ---- //
    NSPredicate *p = [NSPredicate predicateWithFormat:@"deletedAt = nil"];
    [fetchRequest setPredicate:p];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc]
                                 initWithFetchRequest:fetchRequest managedObjectContext:[(id)[[UIApplication sharedApplication] delegate] managedObjectContext]
                                 sectionNameKeyPath:nil cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    [self refetchData];
    
    // table cells arrow
    arrow = [UIImage imageNamed:THEME_CELL_ARROW];
    // table cells call button
    call = [UIImage imageNamed:THEME_CELL_CALL];
    
    currentFont = [UIFont fontWithName:THEME_FONT_GESTA size:18];
    
    // setup the main scroller (using a grid layout)
    self.scroller.contentLayoutMode = MGLayoutGridStyle;
    self.scroller.bottomPadding = 8;
    
    // the tables grid
    tablesGrid = [MGBox boxWithSize:IPHONE_TABLES_GRID];
    tablesGrid.contentLayoutMode = MGLayoutGridStyle;
    [self.scroller.boxes addObject:tablesGrid];
    
    // the features table
    table1 = MGBox.box;
    
    [tablesGrid.boxes addObject:table1];
    table1.sizingMode = MGResizingShrinkWrap;
    
    [self loadTable];
    
    [tablesGrid layout];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation
                                           duration:1];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orient
                                         duration:(NSTimeInterval)duration {
    
    BOOL portrait = UIInterfaceOrientationIsPortrait(orient);
    
    // grid size
    photosGrid.size = portrait
    ? IPHONE_PORTRAIT_GRID
    : IPHONE_LANDSCAPE_GRID;
    
    // relayout the sections
    [self.scroller layoutWithSpeed:duration completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) viewDidUnload{
    [self setScroller:nil];
    
    [super viewDidUnload];
}
- (void)loadTable {
    
    // intro section
    MGTableBoxStyled *menu = MGTableBoxStyled.box;
    [table1.boxes addObject:menu];
    
    // header line
    //MGLineStyled *header = [MGLineStyled lineWithLeft:@"MGBox Demo" right:nil size:ROW_SIZE];
    //header.font = HEADER_FONT;
    //[menu.topLines addObject:header];
    
    // add some MGBoxLines to the box
    MGLineStyled *feedbackLine,
    *complaintsLine,
    *aboutLine,
    *aboutChainLine,
    *contactusLine;
    
    feedbackLine = [MGLineStyled lineWithLeft:@"Feedback & Suggestions" right:arrow size:ROW_SIZE];
    [feedbackLine setBackgroundColor:[UIColor UIColorFromHex:0xe5ddd1] ];
    feedbackLine.font = currentFont;
    feedbackLine.textColor = [UIColor UIColorFromHex:0x442921];
    feedbackLine.textShadowColor = [UIColor whiteColor];
    
    complaintsLine = [MGLineStyled lineWithLeft:@"Complaints" right:arrow size:ROW_SIZE];
    [complaintsLine setBackgroundColor:[UIColor UIColorFromHex:0xe5ddd1]];
    complaintsLine.font = currentFont;
    complaintsLine.textColor = [UIColor UIColorFromHex:0x442921];
    complaintsLine.textShadowColor = [UIColor whiteColor];
    
    
    contactusLine = [MGLineStyled lineWithLeft:@"Contact Us" right:call  size:ROW_SIZE];
    [contactusLine setBackgroundColor:[UIColor UIColorFromHex:0xe5ddd1]];
    contactusLine.font = currentFont;
    contactusLine.textColor = [UIColor UIColorFromHex:0x442921];
    contactusLine.textShadowColor = [UIColor whiteColor];
    
    aboutLine = [MGLineStyled lineWithLeft:@"About App" right:arrow size:ROW_SIZE];
    [aboutLine setBackgroundColor:[UIColor UIColorFromHex:0xe5ddd1]];
    aboutLine.font = currentFont;
    aboutLine.textColor = [UIColor UIColorFromHex:0x442921];
    aboutLine.textShadowColor = [UIColor whiteColor];
    
    aboutChainLine = [MGLineStyled lineWithLeft:@"About SaleSucre" right:arrow size:ROW_SIZE];
    [aboutChainLine setBackgroundColor:[UIColor UIColorFromHex:0xe5ddd1]];
    aboutChainLine.font = currentFont;
    aboutChainLine.textColor = [UIColor UIColorFromHex:0x442921];
    aboutChainLine.textShadowColor = [UIColor whiteColor];

    [menu.topLines addObject:feedbackLine];
    [menu.topLines addObject:complaintsLine];
    [menu.topLines addObject:aboutLine];
    [menu.topLines addObject:aboutChainLine];
    [menu.topLines addObject:contactusLine];
    
    SR_WEAK_SELF wself = self;
    
    // load the features table on tap
    // perform call on tap
    contactusLine.onTap = ^{
        [wself performCall:kSaleSucreHotline];
    };
    
    // load the features table on tap
    aboutChainLine.onTap = ^{
        [wself pushPopupView:ABOUT_CHAIN];
    };
    
    // load the features table on tap
    aboutLine.onTap = ^{
        [wself pushPopupView:ABOUT_APP];
    };
    feedbackLine.onTap = ^{
        [wself sendInAppMail];
    };

    complaintsLine.onTap = ^{
        [wself sendInAppSMS];
    };

}

- (void)performCall:(NSString *)numberToCall
{
    
    [Flurry logEvent:FLURRY_EVENT_CUSTOMER_SERVICE];
    
    DDLogInfo(@"inside PerformCall, calling: %@", numberToCall);
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]] )
    {
        // getting current vew controller
        
        UIWebView *callWebview = [[UIWebView alloc] init];
        
        NSString *telephone = [NSString stringWithFormat:@"tel://%@", numberToCall ];
        DDLogVerbose(@"final telephone is : %@", telephone);
        telephone = [telephone stringByReplacingOccurrencesOfString:@"-" withString:@""];
        telephone = [telephone stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        NSURL *telURL = [NSURL URLWithString:telephone];
        
        [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
        [self.view addSubview:callWebview];
        
        callWebview = nil;
    }
    else
    {
        DDLogInfo(@"this device cannot make phone calls");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Numbers" message:[NSString stringWithFormat:@"This device cannot call, Number(s): %@ ", numberToCall]
                                                       delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        alert = nil;
    }
}

/////// SMS PART
- (void) sendInAppSMS
{
    DDLogInfo(@"sending in App SMS");
    
    
    
	MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
	if([MFMessageComposeViewController canSendText])
	{
		controller.body = @"";
		//controller.recipients = [NSArray arrayWithObjects:@"+201008000840",@"+201001794906",  nil];
        
        NSMutableArray *numbers = [[NSMutableArray alloc] init];
        NSArray *objects = [_fetchedResultsController fetchedObjects];
        
        for (SSContacts *contact in objects)
        {
            [numbers addObject:[contact.number mutableCopy]];
        }
        
        controller.recipients = numbers;
        
		controller.messageComposeDelegate = self;
        //controller.delegate = self;
		[self presentModalViewController:controller animated:YES];
        
	}
}


- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultSent:
            DDLogInfo(@"Message Sent");
            break;
            
        case MessageComposeResultCancelled:
            DDLogInfo(@"User Did Cancel");
            break;
        case MessageComposeResultFailed:
            DDLogInfo(@"Error Sending SMS");
            break;
            
        default:
            DDLogInfo(@"Weired, not supposed to come here");
            break;
    }
    [self dismissModalViewControllerAnimated:YES];
    
}

///// MAIL PART
- (void)sendInAppMail
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        
        mailer.mailComposeDelegate = self;
        
        [mailer setSubject:@"Feedback Via Sale Sucre App"];
        
        NSArray *toRecipients = [NSArray arrayWithObjects:@"salesucreinfo@gmail.com",nil];
        [mailer setToRecipients:toRecipients];
        
        [self presentModalViewController:mailer animated:YES];
        
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"No Email Accounts Configured"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    
    // Remove the mail view
    [self dismissModalViewControllerAnimated:YES];
}

-(void) pushPopupView: (POPUP_VIEW_TYPE) viewType{
    SSPopupViewController *popViewController = [[SSPopupViewController alloc] initWithNibName:@"PopupView" bundle:nil];
    [popViewController setViewType:viewType];
    [self presentPopupViewController:popViewController animationType:KMJPopupViewAnimation];
}


#pragma mark - NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    DDLogWarn(@" %s %d", __PRETTY_FUNCTION__, __LINE__);
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    DDLogWarn(@" %s %d", __PRETTY_FUNCTION__, __LINE__);
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)object
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    DDLogWarn(@" %s %d", __PRETTY_FUNCTION__, __LINE__);
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    DDLogWarn(@" %s %d", __PRETTY_FUNCTION__, __LINE__);
}

@end
