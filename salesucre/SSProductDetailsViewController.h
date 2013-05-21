//
//  SSProductDetailsViewController.h
//  salesucre
//
//  Created by Haitham Reda on 5/22/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KIImagePager;
@class SSMenuItem;
@class Images;

@interface SSProductDetailsViewController : UIViewController

@property (weak, nonatomic) IBOutlet KIImagePager *imagePager;
@property (nonatomic, strong) SSMenuItem *selectedItem;

@end
