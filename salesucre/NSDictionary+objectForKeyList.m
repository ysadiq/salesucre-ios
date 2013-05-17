//
//  NSDictionary+objectForKeyList.m
//  mazayanmore
//
//  Created by Haitham Reda on 3/1/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import "NSDictionary+objectForKeyList.h"


@implementation NSDictionary (objectForKeyList)

- (id)objectForKeyList:(id)key, ...
{
    id object = self;
    va_list ap;
    va_start(ap, key);
    for ( ; key; key = va_arg(ap, id))
    {
        if ([key isKindOfClass:[NSNumber class] ])
        {
            object = [object objectAtIndex:[key integerValue]];
        }
        else
        {
            object = [object objectForKey:key];
        }
    }
    
    va_end(ap);
    return object;
}

@end
