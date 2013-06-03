//
//  SSMoreViewController.h
//  salesucre
//
//  Created by Yahia on 6/3/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MessageUI/MessageUI.h"

@class MGScrollView;

@interface SSMoreViewController : UIViewController<MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate>

@property (nonatomic, weak) IBOutlet MGScrollView *scroller;

@end
