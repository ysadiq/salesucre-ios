//
//  Images.h
//  salesucre
//
//  Created by Haitham Reda on 5/19/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SSCategory, SSMenuItem;

@interface Images : NSManagedObject

@property (nonatomic, retain) NSDate * lastModified;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) SSMenuItem *menuItem;
@property (nonatomic, retain) SSCategory *category;

@end
