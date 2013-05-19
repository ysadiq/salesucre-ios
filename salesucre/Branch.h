//
//  Branch.h
//  salesucre
//
//  Created by Haitham Reda on 5/19/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Branch : NSManagedObject

@property (nonatomic, retain) NSString * branchId;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * lastModified;
@property (nonatomic, retain) id location;
@property (nonatomic, retain) NSArray * phones;
@property (nonatomic, retain) NSManagedObject *address;

@end
