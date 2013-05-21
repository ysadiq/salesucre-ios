//
//  Branch.h
//  salesucre
//
//  Created by Haitham Reda on 5/21/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Branch : NSManagedObject

@property (nonatomic, retain) NSString * branchId;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * lastModified;
@property (nonatomic, retain) id location;
@property (nonatomic, retain) id phones;
@property (nonatomic, retain) NSString * cityId;
@property (nonatomic, retain) NSString * cityName;
@property (nonatomic, retain) NSString * districtId;
@property (nonatomic, retain) NSString * distirctName;

@end
