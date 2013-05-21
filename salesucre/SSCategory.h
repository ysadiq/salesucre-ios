//
//  SSCategory.h
//  salesucre
//
//  Created by Haitham Reda on 5/17/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SSMenuItem;
@class Images;

@interface SSCategory : NSManagedObject

@property NSString * categoryId;
@property NSString * name;
@property NSDate * createdAt;
@property NSDate * lastModified;
@property NSDate * deletedAt;
@property NSNumber * weight;
@property NSSet *menuItems;
@property NSSet *images;

//- (void)addItemsObject:(SSMenuItem *)object;
//- (void)addItems:(NSSet *)objects;

@end
