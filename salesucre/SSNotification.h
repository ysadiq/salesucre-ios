//
//  SSNotification.h
//  salesucre
//
//  Created by Haitham Reda on 5/22/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SSNotification : NSManagedObject

@property (nonatomic, retain) NSString * alert;
@property (nonatomic, retain) NSString * dataAlertExtend;

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * lastModified;
@property (nonatomic, retain) NSDate * deletedAt;

@property (nonatomic, retain) NSNumber * showUP;



@end
