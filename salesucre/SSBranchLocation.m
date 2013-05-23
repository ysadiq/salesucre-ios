//
//  SSBranchLocation.m
//  salesucre
//
//  Created by Haitham Reda on 5/22/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import "SSBranchLocation.h"

@implementation SSBranchLocation

@synthesize coordinate;
@synthesize title = _title;
@synthesize subtitle = _subtitle;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location branch:(NSString *)branch address:(NSString *)address {
    self = [super init];
    if (self != nil) {
        coordinate = location;
        _title = branch;
        _subtitle = address;
    }
    return self;
}


@end
