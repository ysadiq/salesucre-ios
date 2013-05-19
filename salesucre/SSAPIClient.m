//
//  SSAPIClient.m
//  salesucre
//
//  Created by Haitham Reda on 5/17/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import "SSAPIClient.h"
#import "SSCategory.h"
#import "SSMenuItem.h"

#define kAPIBaseURL @"http://api.olitintl.com/APIPlatform/index.php/Version2/"

@implementation SSAPIClient

@synthesize language = _language;
@synthesize retinaScale = _retinaScale;
@synthesize timestamps = _timestamps;

#pragma mark - Singleton & Init
+ (id)sharedInstance
{
    static SSAPIClient *__sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[SSAPIClient alloc] initWithBaseURL:
                            [NSURL URLWithString:kAPIBaseURL]];
    });
    
    return __sharedInstance;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self) {
        //custom settings
        //[self setDefaultHeader:@"x-api-token" value:kToken];
        
        [self setLanguage:[[NSUserDefaults standardUserDefaults] stringForKey:@"language" ] ];
        DDLogInfo(@"#language: %@", self.language);
        
        // enable JSON response & Make JSON operation is the default operation
        [self setParameterEncoding:AFJSONParameterEncoding];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        //"x-api-token: Bearer 08a97b6f5e4b0016270878fc1bd7c84d"
        [self setDefaultHeader:@"x-api-token" value:[NSString stringWithFormat:@"Bearer %@", kToken]];
        
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
        // 401 is invalid token response code
        
        _timestamps = [[NSMutableDictionary alloc] init];
        [_timestamps setValue:@1 forKey:@"categories"];
        [_timestamps setValue:@1 forKey:@"menuItems"];
        
        // retina scale
        // detect weather screen is retina or non-retina
        CGFloat screenScale = [[UIScreen mainScreen] scale];
        NSString *screenValue = [NSString stringWithFormat:@"%1f",screenScale ];
        [self setRetinaScale:[screenValue intValue]];
    }
    
    return self;
}

#pragma mark - Helper Methods
- (NSURL *)imageFullURLFromString:(NSString *)string withWidth:(int)width andHeight:(int)height
{
    /* target: http://betaapi.olitintl.com/APIPlatform/index.php/getImage?
                    image=$path&width=72&height=72&gravity=center&oauth_token=$auth_token */
    
    if (!string || ([string isEqual:[NSNull null]]))
        return nil;
    
    NSString *operationURLString = [NSString
                                    stringWithFormat:@"http://%@%@image=%@&width=%i&height=%i&gravity=center",kAPIHostName, kAPIImagePostfix ,string, width * _retinaScale , height * _retinaScale ];

    return [NSURL URLWithString:operationURLString];
}

#pragma mark - AFIncrementalStore

- (NSURLRequest *)requestForFetchRequest:(NSFetchRequest *)fetchRequest
                             withContext:(NSManagedObjectContext *)context
{
    NSMutableURLRequest *mutableURLRequest = nil;
    if ([fetchRequest.entityName isEqualToString:@"SSCategory"]) {
        
        DDLogInfo(@"constructing request");
        //mutableURLRequest = [self requestWithMethod:@"GET" path:@"/api/rest/products" parameters:nil];
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                                //                                       kToken, @"oauth_token",
                                _language, @"language",
                                @"gt", @"op",
                                [_timestamps valueForKey:@"categories"] , @"lastModified",
                                @"lastModified", @"opKey",
                                @"all", @"limit",
                                nil];
        
        mutableURLRequest = [self requestWithMethod:@"GET" path:@"categories" parameters:params];
    }
    else if ([fetchRequest.entityName isEqualToString:@"SSMenuItem"])
    {
        DDLogInfo(@"constructing request");
        //mutableURLRequest = [self requestWithMethod:@"GET" path:@"/api/rest/products" parameters:nil];
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                                //                                       kToken, @"oauth_token",
                                _language, @"language",
                                @"gt", @"op",
                                //[_timestamps valueForKey:@"categories"] , @"lastModified",
                                @1, @"lastModified",
                                @"lastModified", @"opKey",
                                @"all", @"limit",
                                nil];
        
        mutableURLRequest = [self requestWithMethod:@"GET" path:@"menuItems" parameters:params];
    }
    else if ([fetchRequest.entityName isEqualToString:@"Branch"])
    {
        //http://api.olitintl.com/APIPlatform/index.php/Version2/stores?oauth_token=70da2179f8b4d48b2d652b3b4de2f7e4
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                                //                                       kToken, @"oauth_token",
                                _language, @"language",
                                @"gt", @"op",
                                @1 , @"lastModified",
                                @"lastModified", @"opKey",
                                @"all", @"limit",
                                nil];
        
        mutableURLRequest = [self requestWithMethod:@"GET" path:@"stores" parameters:params];
    }
    else
    {
        DDLogError(@"no entity name found");
    }
    
    return mutableURLRequest;
}

- (id)representationOrArrayOfRepresentationsFromResponseObject:(id)responseObject {
    DDLogVerbose(@"returning results");
    return responseObject; //[responseObject valueForKey:@"results"];
}

- (id)representationOrArrayOfRepresentationsOfEntity:(NSEntityDescription *)entity
                                  fromResponseObject:(id)responseObject
{
    id ro = [super representationOrArrayOfRepresentationsOfEntity:entity fromResponseObject:responseObject];
    DDLogCWarn(@"#weird");
    if ([ro isKindOfClass:[NSDictionary class]]) {
        DDLogInfo(@"kindOfClass NSDictionary");
        id value = nil;
        value = [ro valueForKey:@"results"];
        if (value) {
            return value;
        }
    }
    else if ([ro isKindOfClass:[NSArray class]])
    {
        DDLogInfo(@"kindOfClass NSArray");
        id value = nil;
        value = ro;
        if (value) {
            return value;
        }
    }
    else
    {
        DDLogError(@"#weird kindOfClass!");
    }
    
    return ro;
}

- (NSDictionary *)attributesForRepresentation:(NSDictionary *)representation
                                     ofEntity:(NSEntityDescription *)entity
                                 fromResponse:(NSHTTPURLResponse *)response
{
    NSMutableDictionary *mutablePropertyValues = [[super attributesForRepresentation:representation ofEntity:entity fromResponse:response] mutableCopy];
    //DDLogCVerbose(@"#dump: %@", [representation valueForKey:@"results"]);
    
    if ([entity.name isEqualToString:@"SSCategory"]) {
        DDLogInfo(@"inside entity.name = SSCategory");
        
        //---- change lastModified timestamp ---- //
        if ([[representation valueForKey:@"lastModified"] intValue] > [[_timestamps valueForKey:@"categories"] intValue])
        {
            DDLogInfo(@"new timestamp is higher, assigning new one");
            [_timestamps setValue:[representation valueForKey:@"lastModified"] forKey:@"categories"];
        }
        
        
        //---- end of timestamp ---- //
        
        [mutablePropertyValues setValue:[representation valueForKey:@"_id"] forKey:@"categoryId"];
        [mutablePropertyValues setValue:[representation valueForKey:@"name"] forKey:@"name"];
        
        id createdAtValue = [[representation valueForKey:@"createdAt"] stringValue];
        id lastModifiedValue = [[representation valueForKey:@"lastModified"] stringValue];
        
        if ( createdAtValue && ![createdAtValue isEqual:[NSNull null]] && [createdAtValue isKindOfClass:[NSString class]] )
        {
            //            [mutablePropertyValues setValue:[[NSValueTransformer valueTransformerForName:TTTISO8601DateTransformerName]
            //                                         transformedValue:createdAtValue ] forKey:@"createdAt"];
            NSTimeInterval timeCreated = (NSTimeInterval)[createdAtValue doubleValue];
            [mutablePropertyValues setValue:[NSDate dateWithTimeIntervalSince1970:timeCreated] forKey:@"createdAt"];
        }
        else
            DDLogWarn(@"a7a, %@", [createdAtValue class]);
        
        //        [mutablePropertyValues setValue:[[NSValueTransformer valueTransformerForName:TTTISO8601DateTransformerName]
        //                                         transformedValue:[representation valueForKey:lastModifiedValue] ] forKey:@"lastModified"];
        if ( lastModifiedValue && ![lastModifiedValue isEqual:[NSNull null] ] && [lastModifiedValue isKindOfClass:[NSString class]] )
        {
            NSTimeInterval timeModified = (NSTimeInterval)[lastModifiedValue doubleValue];
            [mutablePropertyValues setValue:[NSDate dateWithTimeIntervalSince1970:timeModified] forKey:@"lastModified"];
        }
        
        [mutablePropertyValues setValue:[representation valueForKey:@"weight"] forKey:@"weight"];
        
    }
    else if ([entity.name isEqualToString:@"SSMenuItem"])
    {
        DDLogInfo(@"inside entity.name: %@", entity.name);
        //---- change lastModified timestamp ---- //
        if ([[representation valueForKey:@"lastModified"] intValue] > [[_timestamps valueForKey:@"menuItems"] intValue])
        {
            DDLogInfo(@"new timestamp is higher, assigning new one");
            [_timestamps setValue:[representation valueForKey:@"lastModified"] forKey:@"menuItems"];
        }
        
        
        //---- end of timestamp ---- //
        
        [mutablePropertyValues setValue:[representation valueForKey:@"_id"] forKey:@"itemId"];
        [mutablePropertyValues setValue:[representation valueForKey:@"name"] forKey:@"name"];
        [mutablePropertyValues setValue:[representation valueForKey:@"description"] forKey:@"itemDescription"];
        NSNumber *price = [NSNumber numberWithInt:[[representation valueForKey:@"price"] intValue] ];
        [mutablePropertyValues setValue:price forKey:@"price"];
        
        id createdAtValue = [[representation valueForKey:@"createdAt"] stringValue];
        id lastModifiedValue = [[representation valueForKey:@"lastModified"] stringValue];
        
        if ( createdAtValue && ![createdAtValue isEqual:[NSNull null]] && [createdAtValue isKindOfClass:[NSString class]] )
        {
            //            [mutablePropertyValues setValue:[[NSValueTransformer valueTransformerForName:TTTISO8601DateTransformerName]
            //                                         transformedValue:createdAtValue ] forKey:@"createdAt"];
            NSTimeInterval timeCreated = (NSTimeInterval)[createdAtValue doubleValue];
            [mutablePropertyValues setValue:[NSDate dateWithTimeIntervalSince1970:timeCreated] forKey:@"createdAt"];
        }
        else
            DDLogWarn(@"a7a, %@", [createdAtValue class]);
        
        //        [mutablePropertyValues setValue:[[NSValueTransformer valueTransformerForName:TTTISO8601DateTransformerName]
        //                                         transformedValue:[representation valueForKey:lastModifiedValue] ] forKey:@"lastModified"];
        if ( lastModifiedValue && ![lastModifiedValue isEqual:[NSNull null] ] && [lastModifiedValue isKindOfClass:[NSString class]] )
        {
            NSTimeInterval timeModified = (NSTimeInterval)[lastModifiedValue doubleValue];
            [mutablePropertyValues setValue:[NSDate dateWithTimeIntervalSince1970:timeModified] forKey:@"lastModified"];
        }
        
        
    }
    else if ([entity.name isEqualToString:@"Images"])
    {
        DDLogInfo(@"entity.name = %@", entity.name);
        id lastModifiedValue = [[representation valueForKey:@"lastModified"] stringValue];
        
        NSTimeInterval timeModified = (NSTimeInterval)[lastModifiedValue doubleValue];
        [mutablePropertyValues setValue:[NSDate dateWithTimeIntervalSince1970:timeModified] forKey:@"lastModified"];
        
        [mutablePropertyValues setValue:[representation valueForKey:@"path"] forKey:@"path"];
    }
    else if ([entity.name isEqualToString:@"Branch"])
    {
        DDLogInfo(@"entity.name = %@", entity.name);
        
        DDLogInfo(@"_id: %@", [representation valueForKey:@"_id"] );
                               
        [mutablePropertyValues setValue:[representation valueForKey:@"_id"] forKey:@"branchId"];
        
        id createdAtValue = [[representation valueForKey:@"createdAt"] stringValue];
        id lastModifiedValue = [[representation valueForKey:@"lastModified"] stringValue];
        
        if ( createdAtValue && ![createdAtValue isEqual:[NSNull null]] && [createdAtValue isKindOfClass:[NSString class]] )
        {
            //            [mutablePropertyValues setValue:[[NSValueTransformer valueTransformerForName:TTTISO8601DateTransformerName]
            //                                         transformedValue:createdAtValue ] forKey:@"createdAt"];
            NSTimeInterval timeCreated = (NSTimeInterval)[createdAtValue doubleValue];
            [mutablePropertyValues setValue:[NSDate dateWithTimeIntervalSince1970:timeCreated] forKey:@"createdAt"];
        }
        if ( lastModifiedValue && ![lastModifiedValue isEqual:[NSNull null]] && [lastModifiedValue isKindOfClass:[NSString class]] )
        {
            NSTimeInterval timeModified = (NSTimeInterval)[lastModifiedValue doubleValue];
            [mutablePropertyValues setValue:[NSDate dateWithTimeIntervalSince1970:timeModified] forKey:@"lastModified"];
        }
        
        [mutablePropertyValues setValue:[representation objectForKey:@"phones"] forKey:@"phones"];
        
    }
    else if ([entity.name isEqualToString:@"SSCity"])
    {
        DDLogInfo(@"entity.name: %@", entity.name);
        [mutablePropertyValues setValue:[representation valueForKey:@"_id"] forKey:@"cityId"];
        [mutablePropertyValues setValue:[representation valueForKey:@"name"] forKey:@"name"];
        [mutablePropertyValues setValue:[representation valueForKey:@"weight"] forKey:@"weight"];
        
        id createdAtValue = [[representation valueForKey:@"createdAt"] stringValue];
        id lastModifiedValue = [[representation valueForKey:@"lastModified"] stringValue];
        
        if ( createdAtValue && ![createdAtValue isEqual:[NSNull null]] && [createdAtValue isKindOfClass:[NSString class]] )
        {
            //            [mutablePropertyValues setValue:[[NSValueTransformer valueTransformerForName:TTTISO8601DateTransformerName]
            //                                         transformedValue:createdAtValue ] forKey:@"createdAt"];
            NSTimeInterval timeCreated = (NSTimeInterval)[createdAtValue doubleValue];
            [mutablePropertyValues setValue:[NSDate dateWithTimeIntervalSince1970:timeCreated] forKey:@"createdAt"];
        }
        if ( lastModifiedValue && ![lastModifiedValue isEqual:[NSNull null]] && [lastModifiedValue isKindOfClass:[NSString class]] )
        {
            NSTimeInterval timeModified = (NSTimeInterval)[lastModifiedValue doubleValue];
            [mutablePropertyValues setValue:[NSDate dateWithTimeIntervalSince1970:timeModified] forKey:@"lastModified"];
        }
        
    }
    else if ([entity.name isEqualToString:@"SSAddress"])
    {
        DDLogInfo(@"entity.name: %@", entity.name);
        
        if ([representation objectForKey:@"street"])
        {
            [mutablePropertyValues setValue:[representation valueForKey:@"street"] forKey:@"street"];
        }
        else
        {
            [mutablePropertyValues setValue:@" " forKey:@"street"];
        }
        if ([representation objectForKey:@"street2"])
        {
            [mutablePropertyValues setValue:[representation valueForKey:@"street2"] forKey:@"street2"];
        }
        [mutablePropertyValues setValue:@"123" forKey:@"id"];
        
        DDLogInfo(@"after parse: %@", mutablePropertyValues);
    }
    else if ([entity.name isEqualToString:@"SSDistrict"])
    {
        DDLogInfo(@"entity.name: %@", entity.name);
        [mutablePropertyValues setValue:[representation valueForKey:@"_id"] forKey:@"districtId"];
        [mutablePropertyValues setValue:[representation valueForKey:@"name"] forKey:@"name"];
        [mutablePropertyValues setValue:[representation valueForKey:@"weight"] forKey:@"weight"];
        
        id createdAtValue = [[representation valueForKey:@"createdAt"] stringValue];
        id lastModifiedValue = [[representation valueForKey:@"lastModified"] stringValue];
        
        if ( createdAtValue && ![createdAtValue isEqual:[NSNull null]] && [createdAtValue isKindOfClass:[NSString class]] )
        {
            //            [mutablePropertyValues setValue:[[NSValueTransformer valueTransformerForName:TTTISO8601DateTransformerName]
            //                                         transformedValue:createdAtValue ] forKey:@"createdAt"];
            NSTimeInterval timeCreated = (NSTimeInterval)[createdAtValue doubleValue];
            [mutablePropertyValues setValue:[NSDate dateWithTimeIntervalSince1970:timeCreated] forKey:@"createdAt"];
        }
        if ( lastModifiedValue && ![lastModifiedValue isEqual:[NSNull null]] && [lastModifiedValue isKindOfClass:[NSString class]] )
        {
            NSTimeInterval timeModified = (NSTimeInterval)[lastModifiedValue doubleValue];
            [mutablePropertyValues setValue:[NSDate dateWithTimeIntervalSince1970:timeModified] forKey:@"lastModified"];
        }
    }
    else {
        
        DDLogError(@"unknown entity: %@ ", [entity description]);
    }
    
    return mutablePropertyValues;
}

- (BOOL)shouldFetchRemoteAttributeValuesForObjectWithID:(NSManagedObjectID *)objectID
                                 inManagedObjectContext:(NSManagedObjectContext *)context
{
    return NO;
}

- (BOOL)shouldFetchRemoteValuesForRelationship:(NSRelationshipDescription *)relationship
                               forObjectWithID:(NSManagedObjectID *)objectID
                        inManagedObjectContext:(NSManagedObjectContext *)context
{
    return NO;
}

@end
