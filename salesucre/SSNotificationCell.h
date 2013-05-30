//
//  SSNotificationCell.h
//  salesucre
//
//  Created by Haitham Reda on 5/22/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSNotification.h"

@interface SSNotificationCell : UITableViewCell

@property (setter = setNotification:) SSNotification *notification;
@property UIFont *defaultFont;

+ (CGFloat)heightForCellWithNotificaction:(SSNotification *)notification;

@end
