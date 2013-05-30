//
//  SSProductDetailsViewController.m
//  salesucre
//
//  Created by Haitham Reda on 5/22/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import "SSProductDetailsViewController.h"
#import "SSMenuItem.h"
#import "Images.h"
#import "UIColor+Helpers.h"
#import <BlockAlertView.h>

#import <KIImagePager.h>

@interface SSProductDetailsViewController () <KIImagePagerDataSource,KIImagePagerDelegate>
@property NSMutableArray *imagesURL;
@end

@implementation SSProductDetailsViewController

@synthesize imagePager = _imagePager;
@synthesize selectedItem = _selectedItem;
@synthesize imagesURL = _imagesURL;
@synthesize textView = _textView;
@synthesize priceLabel;
@synthesize priceTag;
@synthesize facebookButton;
@synthesize twitterButton;

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
    _imagePager.frame = CGRectMake(0.0f,0.0f,320.0f,170.0f);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _imagePager.pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
    _imagePager.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor UIColorFromHex:0xf8f4ed]];
    [self setTitle:_selectedItem.name];
    
    [self.priceLabel setFont:[UIFont fontWithName:THEME_FONT_GESTA size:22]];
    [self.textView setFont:[UIFont fontWithName:THEME_FONT_GESTA size:19]];
    
    DDLogInfo(@"frame: %@", NSStringFromCGRect(_imagePager.frame) );
    
    if (![_selectedItem.price isEqual: [NSNull null]])
    {
        [self.priceLabel setText:[_selectedItem.price stringValue]];
    }
    
    DDLogInfo(@"description: %@", _selectedItem.itemDescription);
    if ( (![_selectedItem.itemDescription isEqual:[NSNull null]] ) && ([_selectedItem.itemDescription length] > 0) )
    {
        NSString *textToView = _selectedItem.itemDescription ;
        textToView = [textToView stringByReplacingOccurrencesOfString:@"newline" withString:@"\n" ];
        
        [_textView setText:textToView];
    }
    
    [self.facebookButton addTarget:self action:@selector(facebookShareTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.twitterButton addTarget:self action:@selector(twitterShareTapped) forControlEvents:UIControlEventTouchUpInside];
    
    SR_WEAK_SELF wself = self;
    
    _imagesURL = [[NSMutableArray alloc] init];
    
    for ( Images *img in [_selectedItem.images allObjects])
    {
        NSString *currImage = [img path];
        NSString *URLToAdd = [[SSAPIClient sharedInstance] imagePagerCompatibleString:currImage withWidth:320 andHeight:170];
        DDLogInfo(@"adding image: %@", URLToAdd);
        [[wself imagesURL] addObject:[URLToAdd copy] ];
    }
    
    [_imagePager reloadData];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - KIImagePager DataSource
- (NSArray *) arrayWithImageUrlStrings
{
//    return [NSArray arrayWithObjects:
//            @"https://raw.github.com/kimar/tapebooth/master/Screenshots/Screen1.png",
//            @"https://raw.github.com/kimar/tapebooth/master/Screenshots/Screen2.png",
//            @"https://raw.github.com/kimar/tapebooth/master/Screenshots/Screen3.png",
//            nil];
    return _imagesURL;
}

- (UIViewContentMode) contentModeForImage:(NSUInteger)image
{
    return UIViewContentModeScaleAspectFit;
}

- (UIImage *) placeHolderImageForImagePager
{
    return [UIImage imageNamed:THEME_GALLERY_PLACEHOLDER];
}

#pragma mark - Social Networks

- (void)facebookShareTapped
{
    DDLogInfo(@"facebook share tapped");
    if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(kiOS6) )
    {
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
        
        SLComposeViewController *facebook = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [facebook setInitialText:[NSString stringWithFormat:@"check out %@ via %@", _selectedItem.name, kSaleSucreTwitterAccount] ];
        [self presentModalViewController:facebook animated:YES];
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    
                    DDLogInfo(@"facebook post cancelled");
                    break;
                case SLComposeViewControllerResultDone:
                    DDLogInfo(@"facebook posted");
                    break;
                default:
                    break;
            }
            
            [facebook dismissViewControllerAnimated:YES completion:Nil];
        };
        facebook.completionHandler = myBlock;
        
        
        }
        else
        {
            DDLogError(@"No facebook account configured");
        }
    }
    else
    {
        DDLogWarn(@"iOS version less than 6.0");
    }
    
}

- (void)twitterShareTapped
{
    DDLogInfo(@"twitter share tapped");
    
    // ios6
    if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(kiOS6) )
    {
        //        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]){
        SLComposeViewController *twitterCompose = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        
        [twitterCompose setInitialText:[NSString stringWithFormat:
                                        @"checkout %@ via %@ \n #salesucre #patisserie #cakes", _selectedItem.name, kSaleSucreTwitterAccount] ];
        

        twitterCompose.completionHandler = ^(SLComposeViewControllerResult result){
            // Handle result, dismiss view controller
            switch (result) {
                case SLComposeViewControllerResultDone:
                    DDLogInfo(@"tweet sent!");
                    break;
                    
                case SLComposeViewControllerResultCancelled:
                    DDLogInfo(@"tweet cancelled!");
                    break;
                    
                default:
                    DDLogWarn(@"some error sending tweet here!");
                    break;
            }
            
            [self dismissViewControllerAnimated:YES
                                     completion:nil];
        };
        
        [self presentViewController:twitterCompose
                           animated:YES
                         completion:nil];
//                }else{
//                    // the user does not have Twitter set up
//                    BlockAlertView *alert = [[BlockAlertView alloc] initWithTitle:@"No Twitter Accounts Found!" message:@"Please configure your Twitter account at iOS device Settings section"];
//                    [alert show];
//            }
    }
    else if ( SYSTEM_VERSION_LESS_THAN(kiOS6) )
    {
        //        if( [TWTweetComposeViewController canSendTweet] ){
        TWTweetComposeViewController *twitterCompose = [[TWTweetComposeViewController alloc] init];
        
        //[twitterCompose addImage:];
        [twitterCompose setInitialText:[NSString stringWithFormat:
                                        @"checkout %@ via %@ \n #salesucre #patisserie #cakes", _selectedItem.name, kSaleSucreTwitterAccount] ];
        
        twitterCompose.completionHandler = ^(TWTweetComposeViewControllerResult result){
            // Handle result, dismiss view controller
            switch (result) {
                case TWTweetComposeViewControllerResultDone:
                    DDLogInfo(@"tweet sent!");
                    break;
                    
                case TWTweetComposeViewControllerResultCancelled:
                    DDLogInfo(@"tweet cencelled!");
                    break;
                    
                default:
                    DDLogInfo(@"some error sending tweet here!");
                    break;
            }
            [self dismissViewControllerAnimated:YES
                                     completion:nil];
        };
        [self presentViewController:twitterCompose
                           animated:YES
                         completion:nil];
//                }else{
//                    // the user hasn't go Twitter set up on their device.
//                    BlockAlertView *alert = [[BlockAlertView alloc] initWithTitle:@"No Twitter Accounts Found!" message:@"Please configure your Twitter account at iOS device Settings section"];
//                    [alert show];
//                }
    }
    
}


@end
