//
//  SSPopupViewController.m
//  salesucre
//
//  Created by Yahia on 6/3/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import "SSPopupViewController.h"

@interface SSPopupViewController ()
@property (nonatomic, assign) NSString *language;
@end

@implementation SSPopupViewController

@synthesize viewType;
@synthesize language;

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
    
//    language = [[NSUserDefaults standardUserDefaults] stringForKey:@"language"];
    
    if(viewType == Terms_And_Conditions)
    {
        [self pushWebView];
    }
    else
        [self pushTextView];
}
-(void) viewDidUnload{
    //[self setViewType:nil];
    //[self setLanguage:nil];
    
    [super viewDidUnload];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//displays terms and condition view
-(void) pushWebView
{
//    NSString *urlAddress;
//    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, -50, 297, 329)];
//    [webView setDelegate:self];
//    
//    if (viewType == Terms_And_Conditions) {
//        urlAddress = [TermsAndConditionsURL stringByAppendingFormat:@"_%@",language];
//    } else if(viewType == ABOUT_CHAIN) {
//        urlAddress = AboutXclusivesURL;
//    }
//    
//    NSURL *url = [NSURL URLWithString:urlAddress];
//    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
//    [webView loadRequest:requestObj];
//    
//    [self.view addSubview:webView];
}

//displays about view
-(void) pushTextView
{
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 297, 249)];
    [textView setDelegate:self];
    [textView setTextAlignment:NSTextAlignmentCenter];
    [textView setDataDetectorTypes:UIDataDetectorTypeLink];
    [textView setEditable:NO];
    [textView setFont:[UIFont fontWithName:kFontMyriadProRegular size:18]];
    [textView setTextColor:[UIColor darkGrayColor]];
    
    
    if(viewType == ABOUT_APP)
    {
        NSString *appVersion = [NSString stringWithFormat:@"%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
        
        [textView setText:[NSString stringWithFormat:@"App Developed by OLIT S.A.E\n http://olitintl.com\n\n\nApp version:  %@", appVersion]];
    }else if(viewType == ABOUT_CHAIN)
    {
        [textView setText:[NSString stringWithFormat:@"replace it with chain text"]];
    }
    
    [textView setUserInteractionEnabled:false];
    [self.view addSubview:textView];
}


@end
