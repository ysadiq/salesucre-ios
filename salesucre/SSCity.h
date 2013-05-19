//
//  SSCity.h
//  salesucre
//
//  Created by Haitham Reda on 5/19/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SSAddress;

@interface SSCity : NSManagedObject

@property (nonatomic, retain) NSString * cityId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * weight;
@property (nonatomic, retain) NSDate * lastModified;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSManagedObject *district;
@property (nonatomic, retain) SSAddress *address;

- (void)dumpCurrentCity;

@end
