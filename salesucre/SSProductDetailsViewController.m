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

#import <KIImagePager.h>

@interface SSProductDetailsViewController () <KIImagePagerDataSource,KIImagePagerDelegate>
@property NSMutableArray *imagesURL;
@end

@implementation SSProductDetailsViewController

@synthesize imagePager = _imagePager;
@synthesize selectedItem = _selectedItem;
@synthesize imagesURL = _imagesURL;
@synthesize textView = _textView;

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
    [self.view setBackgroundColor:[UIColor clearColor]];
    
    DDLogInfo(@"frame: %@", NSStringFromCGRect(_imagePager.frame) );
    
    DDLogInfo(@"description: %@", _selectedItem.itemDescription);
    if ( (![_selectedItem.itemDescription isEqual:[NSNull null]] ) && ([_selectedItem.itemDescription length] > 0) )
    {
        [_textView setText:_selectedItem.itemDescription];
    }
    
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


@end
