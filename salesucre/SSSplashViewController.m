//
//  SSSplashViewController.m
//  salesucre
//
//  Created by Haitham Reda on 5/17/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import "SSSplashViewController.h"

@interface SSSplashViewController ()

@end

@implementation SSSplashViewController

@synthesize activity, modalView, splashImage;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //[self.modalView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Default"]] ];
        DDLogInfo(@"init splash view, height: %f", [UIScreen mainScreen].bounds.size.height);
        self.view.frame = CGRectMake(0.0f, 0.0f, 320.0f, [UIScreen mainScreen].bounds.size.height);
        self.splashImage.frame =CGRectMake(0.0f, 0.0f, 320.0f, [UIScreen mainScreen].bounds.size.height);
        DDLogInfo(@"splash image height: %f", self.splashImage.frame.size.height);
        if ([UIScreen mainScreen].bounds.size.height > 480)
        {
            [self.splashImage setImage:[UIImage imageNamed:@"Default-568h"]];
        }
        else
        {
            [self.splashImage setImage:[UIImage imageNamed:@"Default"]];
        }
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    DDLogWarn(@"splash is visible");
    [self showSplash];
}
- (void)viewDidUnload
{
    [self setActivity:nil];
    [self setModalView:nil];
    [self setSplashImage:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showSplash
{
    
    [self.splashImage setImage: [UIImage imageNamed:@"Default"] ];
    [self.modalView addSubview:self.splashImage];
    //[[HRProgressView progressPanel] showLoadingPanel ];
    
    self.activity  = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    [self.activity setFrame:CGRectMake(142.0f, [[UIScreen mainScreen] bounds].size.height - 80.0, 20.0f, 20.0f) ];
    
    
    DDLogInfo(@"Start Animating");
    [self.activity startAnimating];
    [self.modalView addSubview:self.activity];
}

- (void)hideSplash
{
    DDLogInfo(@"hiding splash");
    //[[HRProgressView progressPanel] hideLoadingPanel];
    [self.activity stopAnimating];
    [self.activity removeFromSuperview];
    
    //[self.modalViewController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    
    [self.modalViewController dismissModalViewControllerAnimated:YES];
    self.activity = nil;
    self.splashImage = nil;
    self.modalView = nil;
    DDLogInfo(@"All Clear here");
}
@end
