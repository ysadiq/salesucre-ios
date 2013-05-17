//
//  SSIncrementalStore.m
//  salesucre
//
//  Created by Haitham Reda on 5/17/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import "SSIncrementalStore.h"
#import "SSAPIClient.h"

@implementation SSIncrementalStore

+ (void)initialize {
    [NSPersistentStoreCoordinator registerStoreClass:self forStoreType:[self type]];
}

+ (NSString *)type {
    return NSStringFromClass(self);
}

+ (NSManagedObjectModel *)model {
    return [[NSManagedObjectModel alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:kDataModelStoreName withExtension:@"xcdatamodeld"]];
}

- (id<AFIncrementalStoreHTTPClient>)HTTPClient {
    return [SSAPIClient sharedInstance];
}

@end
