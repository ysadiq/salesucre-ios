//
//  SSBranchDetailsViewController.m
//  salesucre
//
//  Created by Haitham Reda on 5/21/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import "SSBranchDetailsViewController.h"
#import "Branch.h"

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
