//
//  Branch.h
//  salesucre
//
//  Created by Haitham Reda on 6/4/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Branch : NSManagedObject

@property (nonatomic, retain) NSString * branchId;
@property (nonatomic, retain) NSString * cityId;
@property (nonatomic, retain) NSString * cityName;
@property (nonatomic, retain) NSNumber * cityWeight;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * deletedAt;
@property (nonatomic, retain) NSString * distirctName;
@property (nonatomic, retain) NSString * districtId;
@property (nonatomic, retain) NSNumber * districtWeight;
@property (nonatomic, retain) NSDate * lastModified;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) id phones;
@property (nonatomic, retain) NSString * street;
@property (nonatomic, retain) NSString * street2;

@end
