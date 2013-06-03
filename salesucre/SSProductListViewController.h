//
//  SSProductListViewController.h
//  salesucre
//
//  Created by Haitham Reda on 5/18/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCategory.h"

@interface SSProductListViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) SSCategory *currentcategory;
@property id productToPass;
@property (nonatomic, assign) BOOL isLegacyiOS;

@end
