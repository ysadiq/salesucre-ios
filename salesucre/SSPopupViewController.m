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
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 297, 320)];
    [textView setDelegate:self];
    [textView setScrollEnabled:YES];
    [textView setTextAlignment:NSTextAlignmentCenter];
    [textView setDataDetectorTypes:UIDataDetectorTypeLink];
    [textView setEditable:NO];
    textView.textColor = [UIColor UIColorFromHex:0x442921];
    
    
    if(viewType == ABOUT_APP)
    {
        [textView setFont:[UIFont fontWithName:THEME_FONT_GESTA size:18]];
        NSString *appVersion = [NSString stringWithFormat:@"%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
        
        [textView setText:[NSString stringWithFormat:@"App Developed by OLIT S.A.E\n Haitham Reda: @haitham_reda \n \n http://olitintl.com\n\n\nApp version:  %@", appVersion]];
    }else if(viewType == ABOUT_CHAIN)
    {
        [textView setFont:[UIFont fontWithName:THEME_FONT_GESTA size:15]];
        [textView setScrollEnabled:YES];
        [textView setText:[NSString stringWithFormat:@"Salé Sucré Pâtisserie was established in 1999, Today we operate 8 stores all over Cairo.Our bread, pastries and gateaux are freshly baked every morning and then delivered to each store by 8am daily.\n Our Products: \nBringing you traditional recipes and innovative ideas in order to bringa little piece of France to you. With this in mind, we produce the most prestigious and refined fresh desserts and patisserie with extraordinary taste, texture and sensation. We source only the finest ingredients, fresh fruit and produce at the peak of each season, French and Belgian chocolateand European style butter are a few examples."]];
    }
    
    [textView setUserInteractionEnabled:false];
    [self.view addSubview:textView];
}


@end
