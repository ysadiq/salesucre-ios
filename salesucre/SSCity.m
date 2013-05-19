//
//  SSCity.m
//  salesucre
//
//  Created by Haitham Reda on 5/19/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import "SSCity.h"
#import "SSAddress.h"
#import "SSDistrict.h"

@implementation SSCity

@dynamic cityId;
@dynamic name;
@dynamic weight;
@dynamic lastModified;
@dynamic createdAt;
@dynamic district;
@dynamic address;

- (void)dumpCurrentCity
{
    DDLogInfo(@" || --------------- ||");
    DDLogInfo(@"cityId: %@", [self cityId]);
    DDLogInfo(@"name: %@", [self name]);
    DDLogInfo(@"weight: %i", [self.weight integerValue]);
    DDLogInfo(@" || --------------- ||");
}

@end
