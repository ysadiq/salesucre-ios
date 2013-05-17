//
//  SSSplashViewController.h
//  salesucre
//
//  Created by Haitham Reda on 5/17/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSSplashViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIView *modalView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activity;
@property (nonatomic, weak) IBOutlet UIImageView *splashImage;

- (void)showSplash;
- (void)hideSplash;

@end
