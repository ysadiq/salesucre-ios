//
//  SSCell.h
//  salesucre
//
//  Created by Haitham Reda on 5/17/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSCategory.h"
#import "SSMenuItem.h"


@interface SSCell : UITableViewCell

- (void)setCateforiesData:(SSCategory *)currentCategory withLanguage:(NSString *)language;
- (void)setMenuItem:(SSMenuItem *)currentItem;

@end
