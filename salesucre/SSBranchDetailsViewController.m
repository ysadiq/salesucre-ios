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
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    DDLogInfo(@"current branch: %@", _currentBranch.distirctName);
    
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

@end
