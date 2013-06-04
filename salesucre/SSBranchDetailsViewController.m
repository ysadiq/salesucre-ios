//
//  SSBranchDetailsViewController.m
//  salesucre
//
//  Created by Haitham Reda on 5/21/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import "SSBranchDetailsViewController.h"
#import "Branch.h"
#import "SSBranchLocation.h"
#import "UIColor+Helpers.h"
#import <BlockActionSheet.h>
#import <SVProgressHUD.h>

@interface SSBranchDetailsViewController ()

@end

@implementation SSBranchDetailsViewController

@synthesize currentBranch = _currentBranch;
@synthesize map = _map;
@synthesize textView = _textView;
@synthesize callButton = _callButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_map setFrame:CGRectMake(0.0f, 0.0f, 320.0f, 252.0f)];
}
- (void)viewDidUnload
{
    [self setCurrentBranch:nil];
    [self setMap:nil];
    [self setTextView:nil];
    [self setCallButton:nil];
    
    [super viewDidUnload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setTitle:_currentBranch.distirctName];
    [self.view setBackgroundColor:[UIColor UIColorFromHex:0xf8f4ed]];
    
    [self.callButton addTarget:self action:@selector(userDidTapCall) forControlEvents:UIControlEventTouchUpInside];
    
    [self.textView setFont:[UIFont fontWithName:THEME_FONT_GESTA size:15] ];
    self.textView.textColor = [UIColor UIColorFromHex:0x673F32];
    [self.textView setBackgroundColor:[UIColor clearColor]];
    
    
    // ---- Flurry ---- //
    NSDictionary *fProductViewd = [NSDictionary dictionaryWithObjectsAndKeys:
                                   (id)_currentBranch.distirctName ,@"Branch District",
                                   (id)_currentBranch.street , @"Street Address" ,nil] ;
    
    [Flurry logEvent:FLURRY_EVENT_BRANCHES_VIEWD withParameters:fProductViewd];
    
    NSString *text = [NSString stringWithFormat:@"%@\n", _currentBranch.distirctName];
    
    if (_currentBranch.street)
    {
        text = [text stringByAppendingFormat:@"%@\n",_currentBranch.street];
    }

    if (_currentBranch.street2)
    {
        text = [text stringByAppendingString:_currentBranch.street2];
    }
    
    [_textView setText:text];
    
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = _currentBranch.latitude;
    coordinate.longitude = _currentBranch.longitude;
    
    
    MKCoordinateRegion region = { {0.0,0.0} , {0.0,0.0} };
    region.center.latitude = coordinate.latitude;
    region.center.longitude = coordinate.longitude;
    region.span.longitudeDelta = 0.02f;
    region.span.latitudeDelta = 0.02f;
    [_map setRegion:region animated:YES];
    
    SSBranchLocation *pin = [[SSBranchLocation alloc] initWithCoordinates:coordinate
                                                                   branch:_currentBranch.distirctName
                                                                  address:_currentBranch.street];
    
    
    [_map addAnnotation:pin];
    [_map selectAnnotation:pin animated:YES];
    [_map setZoomEnabled:YES];
    [_map setScrollEnabled:YES];
    [_map setDelegate:self];
    
    
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)userDidTapCall
{
    DDLogInfo(@"should be calling now, numbers: %@", _currentBranch.phones);
    
    // ---- Flurry ---- //
    NSDictionary *fProductViewd = [NSDictionary dictionaryWithObjectsAndKeys:
                                   (id)_currentBranch.distirctName ,@"Branch District",
                                   (id)_currentBranch.street , @"Street Address" ,nil] ;
    
    [Flurry logEvent:FLURRY_EVENT_BRANCHES_INTERACTION withParameters:fProductViewd];
    
    if ([_currentBranch.phones count] > 0)
    {
        DDLogInfo(@"is array");
        BlockActionSheet *sheet = [[BlockActionSheet alloc] initWithTitle:@"Which Number?"];
        
        SR_WEAK_SELF wself = self;
        int i = 0;
        
        for (NSString *number in _currentBranch.phones)
        {
            [sheet addButtonWithTitle:number atIndex:i block:^{
                [wself performSelectorOnMainThread:@selector(performCall:) withObject:number waitUntilDone:YES];
            }];
            
            i++;
        }
        
        [sheet setCancelButtonWithTitle:@"Cancel" atIndex:i block:nil];
        [sheet showInView:self.view];
    }
//    else if ([_currentBranch.phones count] == 1 )
//    {
//        DDLogInfo(@"is string");
//        [self performSelectorOnMainThread:@selector(performCall:) withObject:[_currentBranch.phones stringValue] waitUntilDone:YES];
//    }
    else
    {
        DDLogError(@"deep shit here");
    }
}

- (void)performCall:(NSString *)number
{
    DDLogInfo(@"inside PerformCall, calling: %@", number);
    
    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]] )
    {
        // getting current vew controller
        
        UIWebView *callWebview = [[UIWebView alloc] init];
        
        NSString *telephone = [NSString stringWithFormat:@"tel://%@", number ];
        
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
        [SVProgressHUD showErrorWithStatus:@"This device cannot perform a phone call"];
    }

}

@end
