//
//  SSAddress.h
//  salesucre
//
//  Created by Haitham Reda on 5/19/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Branch;

@interface SSAddress : NSManagedObject

@property (nonatomic, retain) NSManagedObject *city;
@property (nonatomic, retain) NSManagedObject *district;
@property (nonatomic, retain) Branch *branch;

@end
