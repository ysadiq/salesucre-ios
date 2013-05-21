//
//  SSBranchesViewController.h
//  salesucre
//
//  Created by Haitham Reda on 5/19/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Branch.h"

@interface SSBranchesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property id branchToPass;

@end
