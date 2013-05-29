//
//  SSProductDetailsViewController.h
//  salesucre
//
//  Created by Haitham Reda on 5/22/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

@class KIImagePager;
@class SSMenuItem;
@class Images;

@interface SSProductDetailsViewController : UIViewController

@property (weak, nonatomic) IBOutlet KIImagePager *imagePager;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIImageView *priceTag;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (nonatomic, strong) SSMenuItem *selectedItem;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end
