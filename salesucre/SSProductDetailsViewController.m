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
#import <SVProgressHUD.h>
#import <UIImageView+AFNetworking.h>

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
    _imagePager.pageControl.currentPageIndicatorTintColor = [UIColor UIColorFromHex:0xffa100];
    _imagePager.pageControl.pageIndicatorTintColor = [UIColor whiteColor];

}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor UIColorFromHex:0xf8f4ed]];
    [self setTitle:_selectedItem.name];
    
    [self.priceLabel setFont:[UIFont fontWithName:THEME_FONT_GESTA size:18]];
    [self.textView setFont:[UIFont fontWithName:THEME_FONT_GESTA size:19]];
    
    self.textView.textColor = [UIColor UIColorFromHex:0xE65C00];
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
    
    // ---- Flurry ---- //
    NSDictionary *fProductViewd = [NSDictionary dictionaryWithObjectsAndKeys:
                                      (id)_selectedItem.name ,@"Product Name", nil] ;
    [Flurry logEvent:FLURRY_EVENT_PRODUCT_VIEWD withParameters:fProductViewd];
    
    
    // ---- activity view ---- //
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner setFrame:CGRectMake(150.0f, 68.0f, 20.0f, 20.0f)];
    [spinner startAnimating];
    [_imagePager addSubview:spinner];
    spinner = nil;
    
    SR_WEAK_SELF wself = self;
    
    _imagesURL = [[NSMutableArray alloc] init];
    
    for ( Images *img in [_selectedItem.images allObjects])
    {
        NSString *currImage = [img path];
        NSString *URLToAdd = [[SSAPIClient sharedInstance] imagePagerCompatibleString:currImage withWidth:320 andHeight:170];
        ///DDLogInfo(@"adding image: %@", URLToAdd);
        [[wself imagesURL] addObject:[URLToAdd copy] ];
    }
    
    [_imagePager reloadData];

}

- (void)viewDidUnload
{
    [self setImagePager:nil];
    [self setSelectedItem:nil];
    [self setImagesURL:nil];
    [self setTextView:nil];
    [self setPriceLabel:nil];
    [self setPriceTag:nil];
    [self setTwitterButton:nil];
    [self setFacebookButton:nil];
    
    [super viewDidUnload];
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
    
    // ---- Flurry ---- //
    NSDictionary *fProductViewd = [NSDictionary dictionaryWithObjectsAndKeys:
                                   (id)_selectedItem.name ,@"Product Name",
                                   (id)@"facebook" , @"Social Network" ,nil] ;
    
    [Flurry logEvent:FLURRY_EVENT_PRODUCT_INTERACTION withParameters:fProductViewd];
    
    if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(kiOS6) )
    {
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]){
        
        SLComposeViewController *facebook = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [facebook setInitialText:[NSString stringWithFormat:@"check out %@ via %@", _selectedItem.name, kSaleSucreTwitterAccount] ];
            
            if (_imagesURL && ([_imagesURL count] > 0 ))
            {
                UIImage *imageToShare = [[UIImage alloc] init];
                
                @try {
//                    NSURL *url = [NSURL URLWithString:[_imagesURL objectAtIndex:0]];
//                    [facebook addImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:url]] ];
                    for (id view in [_imagePager subviews])
                    {
                        DDLogInfo(@"current view: %@, type: %@", view , [view class]);
                        if ( [view isKindOfClass:[UIScrollView class]] )
                        {
                            for (id subView in [view subviews])
                            {
                                if ([subView isKindOfClass:[UIImageView class]])
                                {
                                    imageToShare = [(UIImageView *)subView image];
                                    [facebook addImage:imageToShare];
                                    break;
                                }
                            }
                            
                            break;
                        }
                    }
                    
                }
                @catch (NSException *exception) {
                    DDLogError(@"Exception: %@", exception);
                }
            }
            
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
        [SVProgressHUD showErrorWithStatus:@"Facebook share available only for iOS 6.0 or more"];
    }
    
}

- (void)twitterShareTapped
{
    DDLogInfo(@"twitter share tapped");
    
    // ---- Flurry ---- //
    NSDictionary *fProductViewd = [NSDictionary dictionaryWithObjectsAndKeys:
                                   (id)_selectedItem.name ,@"Product Name",
                                   (id)@"twitter" , @"Social Network" ,nil] ;
    
    [Flurry logEvent:FLURRY_EVENT_PRODUCT_INTERACTION withParameters:fProductViewd];
    
    // ios6
    if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(kiOS6) )
    {
        //        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]){
        SLComposeViewController *twitterCompose = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        
        [twitterCompose setInitialText:[NSString stringWithFormat:
                                        @"checkout %@ via %@ \n #salesucre #patisserie #cakes", _selectedItem.name, kSaleSucreTwitterAccount] ];
        if (_imagesURL && ([_imagesURL count] > 0 ))
        {
            UIImage *imageToShare = [[UIImage alloc] init];
            
            @try {
                for (id view in [_imagePager subviews])
                {
                    DDLogInfo(@"current view: %@, type: %@", view , [view class]);
                    if ( [view isKindOfClass:[UIScrollView class]] )
                    {
                        for (id subView in [view subviews])
                        {
                            if ([subView isKindOfClass:[UIImageView class]])
                            {
                                imageToShare = [(UIImageView *)subView image];
                                [twitterCompose addImage:imageToShare];
                                break;
                            }
                        }
                        
                        break;
                    }
                }
                
            }
            @catch (NSException *exception) {
                DDLogError(@"Exception: %@", exception);
            }
        }
        
        
        twitterCompose.completionHandler = ^(SLComposeViewControllerResult result){
            // Handle result, dismiss view controller
            switch (result) {
                case SLComposeViewControllerResultDone:
                    DDLogInfo(@"tweet sent!");
                    [SVProgressHUD showSuccessWithStatus:@"Tweet Posted!"];
                    break;
                    
                case SLComposeViewControllerResultCancelled:
                    DDLogInfo(@"tweet cancelled!");
                    [SVProgressHUD showErrorWithStatus:@"Tweet Cancelled!"];
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
        
        if (_imagesURL && ([_imagesURL count] > 0 ))
        {
            UIImage *imageToShare = [[UIImage alloc] init];
            
            @try {
                for (id view in [_imagePager subviews])
                {
                    DDLogInfo(@"current view: %@, type: %@", view , [view class]);
                    if ( [view isKindOfClass:[UIScrollView class]] )
                    {
                        for (id subView in [view subviews])
                        {
                            if ([subView isKindOfClass:[UIImageView class]])
                            {
                                imageToShare = [(UIImageView *)subView image];
                                [twitterCompose addImage:imageToShare];
                                break;
                            }
                        }
                        
                        break;
                    }
                }
                
            }
            @catch (NSException *exception) {
                DDLogError(@"Exception: %@", exception);
            }
        }
        
        twitterCompose.completionHandler = ^(TWTweetComposeViewControllerResult result){
            // Handle result, dismiss view controller
            switch (result) {
                case TWTweetComposeViewControllerResultDone:
                    DDLogInfo(@"tweet sent!");
                    [SVProgressHUD showSuccessWithStatus:@"Tweet Posted!"];
                    break;
                    
                case TWTweetComposeViewControllerResultCancelled:
                    DDLogInfo(@"tweet cencelled!");
                    [SVProgressHUD showErrorWithStatus:@"Tweet Cancelled"];
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
