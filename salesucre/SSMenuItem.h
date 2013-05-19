//
//  SSMenuItem.h
//  salesucre
//
//  Created by Haitham Reda on 5/18/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SSCategory;

@interface SSMenuItem : NSManagedObject

@property (nonatomic, retain) NSString * itemId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * itemDescription;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * lastModified;
@property (nonatomic, retain) NSSet *categories;
@property (nonatomic, retain) NSSet *images;

//- (void)addCategoryObject:(SSCategory *)object;

@end
