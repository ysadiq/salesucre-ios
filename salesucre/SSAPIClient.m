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
#import "Branch.h"

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

- (NSString *)imagePagerCompatibleString:(NSString *)image withWidth:(int)width andHeight:(int)height
{
    NSString *operationURLString = [NSString
                                    stringWithFormat:@"http://%@%@image=%@&width=%i&height=%i&gravity=center",kAPIHostName, kAPIImagePostfix ,image, width * _retinaScale , height * _retinaScale ];
    operationURLString = [operationURLString stringByReplacingOccurrencesOfString:@"/vol/" withString:@"/var/"];
    
    return operationURLString;
}

- (void)prepareTimestamps
{
    _timestamps = [[[NSUserDefaults standardUserDefaults] objectForKey:@"timestamps"] mutableCopy];
    DDLogInfo(@"timestamp after init: %@", _timestamps);
}

- (BOOL)saveTimestampsIfChanged
{
    NSDictionary *temp = [[NSUserDefaults standardUserDefaults] objectForKey:@"timestamps"];
    
    if ([_timestamps isEqualToDictionary:temp]) {
        DDLogInfo(@"#timestamps not changed");
        return YES;
    }
    else
    {
        DDLogWarn(@"changing timestamps");
        [[NSUserDefaults standardUserDefaults] setObject:[_timestamps copy] forKey:@"timestamps"];
        BOOL retVal = [[NSUserDefaults standardUserDefaults] synchronize];
        return retVal;
    }
}

#pragma mark - AFIncrementalStore

- (NSURLRequest *)requestForFetchRequest:(NSFetchRequest *)fetchRequest
                             withContext:(NSManagedObjectContext *)context
{
    NSMutableURLRequest *mutableURLRequest = nil;
    
    if ([fetchRequest.entityName isEqualToString:@"SSCategory"]) {
        
        DDLogInfo(@"constructing request");
        
        NSString * time = [NSString stringWithFormat:@"%i",[[_timestamps valueForKey:@"categories"] intValue] ];
        DDLogInfo(@"timest: %@", time);
        
        //mutableURLRequest = [self requestWithMethod:@"GET" path:@"/api/rest/products" parameters:nil];
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                                _language, @"language",
                                @"gt", @"op",
                                @"lastModified", @"opKey",
                                time , @"lastModified",
                                @"all", @"limit",
                                nil];
        
        mutableURLRequest = [self requestWithMethod:@"GET" path:@"categories" parameters:params];
    }
    else if ([fetchRequest.entityName isEqualToString:@"SSMenuItem"])
    {
        DDLogInfo(@"constructing request");
        NSString * time = [NSString stringWithFormat:@"%i",[[_timestamps valueForKey:@"menuItems"] intValue] ];
        DDLogInfo(@"timest: %@", time);
        
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                                _language , @"language",
                                @"gt", @"op",
                                time , @"lastModified",
                                @"lastModified", @"opKey",
                                @"all", @"limit",
                                nil];
        
        mutableURLRequest = [self requestWithMethod:@"GET" path:@"menuItems" parameters:params];
    }
    else if ([fetchRequest.entityName isEqualToString:@"Branch"])
    {
        
        NSString * time = [NSString stringWithFormat:@"%i",[[_timestamps valueForKey:@"branches"] intValue] ];
        DDLogInfo(@"timest: %@", time);
        
        //http://api.olitintl.com/APIPlatform/index.php/Version2/stores?oauth_token=70da2179f8b4d48b2d652b3b4de2f7e4
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                                _language, @"language",
                                @"gt", @"op",
                                time , @"lastModified",
                                @"lastModified", @"opKey",
                                @"all", @"limit",
                                nil];
        
        mutableURLRequest = [self requestWithMethod:@"GET" path:@"stores" parameters:params];
    }
    else if ([fetchRequest.entityName isEqualToString:@"SSNotification"])
    {
        /*
        curl -X GET \
        -H "X-Parse-Application-Id: 73HJhonGfFxg4ZcSP6oY4e1k7OoyP4Xiw0ea2nl4" \
        -H "X-Parse-REST-API-Key: S8gawjiwXYEKIz97FeT5kOKITVLkN1ALqBo8iKJO" \
        https://api.parse.com/1/classes/SSNotifications/
         */
        DDLogInfo(@"inside entity.name: %@", fetchRequest.entityName);
        
        NSURL *notificationURL = [NSURL URLWithString:@"https://api.parse.com/1/classes/SSNotifications"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:notificationURL];
        

        [self setDefaultHeader:@"X-Parse-Application-Id" value:kParseAppId];
        [self setDefaultHeader:@"X-Parse-REST-API-Key" value:kParseRESTAPIKey];
        [request setHTTPMethod:@"GET"];
        
        
        DDLogInfo(@"%@", [self defaultValueForHeader:@"X-Parse-Application-Id"]);
        DDLogInfo(@"%@", [self defaultValueForHeader:@"X-Parse-REST-API-Key"]);
        DDLogInfo(@"request: %@", request);
        
        mutableURLRequest = request;

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
        
        // ---- deletedAt ---- //
        id deletedAtValue = [[representation valueForKey:@"deletedAt"] stringValue];
        if ([representation valueForKey:@"deletedAt"])
        {
            DDLogWarn(@"#deletedAt detected , category: %@", [representation valueForKey:@"name"]);
            NSTimeInterval timeDeleted = (NSTimeInterval)[deletedAtValue doubleValue];
            [mutablePropertyValues setValue:[NSDate dateWithTimeIntervalSince1970:timeDeleted] forKey:@"deletedAt"];
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
        else
        {
            DDLogInfo(@"old timestamp is heighr: %i", [[representation valueForKey:@"lastModified"] intValue]);
        }
        
        // ---- deletedAt ---- //
        id deletedAtValue = [[representation valueForKey:@"deletedAt"] stringValue];
        if ([representation valueForKey:@"deletedAt"])
        {
            DDLogWarn(@"#deletedAt detected , category: %@", [representation valueForKey:@"name"]);
            NSTimeInterval timeDeleted = (NSTimeInterval)[deletedAtValue doubleValue];
            [mutablePropertyValues setValue:[NSDate dateWithTimeIntervalSince1970:timeDeleted] forKey:@"deletedAt"];
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
        
                               
        [mutablePropertyValues setValue:[representation valueForKey:@"_id"] forKey:@"branchId"];
        
        //---- change lastModified timestamp ---- //
        if ([[representation valueForKey:@"lastModified"] intValue] > [[_timestamps valueForKey:@"branches"] intValue])
        {
            DDLogInfo(@"new timestamp is higher, assigning new one");
            [_timestamps setValue:[representation valueForKey:@"lastModified"] forKey:@"branches"];
        }
        else
        {
            DDLogInfo(@"old timestamp is heighr: %i", [[representation valueForKey:@"lastModified"] intValue]);
        }
        
        // ---- deletedAt ---- //
        id deletedAtValue = [[representation valueForKey:@"deletedAt"] stringValue];
        if ([representation valueForKey:@"deletedAt"])
        {
            DDLogWarn(@"#deletedAt detected , category: %@", [representation valueForKey:@"name"]);
            NSTimeInterval timeDeleted = (NSTimeInterval)[deletedAtValue doubleValue];
            [mutablePropertyValues setValue:[NSDate dateWithTimeIntervalSince1970:timeDeleted] forKey:@"deletedAt"];
        }
        
        // ---- Street, City & District ---- //
        DDLogInfo(@"street: %@", [representation objectForKeyList:@"address",@"street",nil]);
        
        [mutablePropertyValues setValue:[representation objectForKeyList:@"address",@"street",nil] forKey:@"street"];
        if ([representation objectForKeyList:@"address",@"street2",nil])
        {
            [mutablePropertyValues setValue:[representation objectForKeyList:@"address",@"street2",nil] forKey:@"street2"];
        }
        else
        {
            [mutablePropertyValues setValue:nil forKey:@"street2"];
        }
        
        
        [mutablePropertyValues setValue:[representation objectForKeyList:@"address",@"city",@"_id",nil] forKey:@"cityId"];
        [mutablePropertyValues setValue:[representation objectForKeyList:@"address",@"city",@"name",nil] forKey:@"cityName"];
        [mutablePropertyValues setValue:[representation objectForKeyList:@"address",@"city",@"weight",nil] forKey:@"cityWeight"];
        
        [mutablePropertyValues setValue:[representation objectForKeyList:@"address",@"district",@"_id",nil] forKey:@"districtId"];
        [mutablePropertyValues setValue:[representation objectForKeyList:@"address",@"district",@"name",nil] forKey:@"distirctName"];
        [mutablePropertyValues setValue:[representation objectForKeyList:@"address",@"district",@"weight",nil] forKey:@"districtWeight"];
        
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
        
        // ---- location ---- //
        if ([representation objectForKeyList:@"location",nil] \
            && [representation objectForKeyList:@"location",@"loc",nil])
        {
            DDLogWarn(@"location found, assign");
            [mutablePropertyValues setValue:[representation objectForKeyList:@"location",@"loc",@"lat",nil] forKey:@"latitude"];
            [mutablePropertyValues setValue:[representation objectForKeyList:@"location",@"loc",@"lon",nil] forKey:@"longitude"];
        }
        else
        {
            DDLogError(@"location not found, %@", [representation objectForKeyList:@"address",nil]);
        }
    }
    else if ([entity.name isEqualToString:@"SSNotification"])
    {
        DDLogInfo(@"entity.name: %@", entity.name);
        
        [mutablePropertyValues setValue:[representation valueForKey:@"content"] forKey:@"content"];
        [mutablePropertyValues setValue:[representation valueForKey:@"showUP"] forKey:@"showUP"];
        
        [mutablePropertyValues setValue:[representation valueForKey:@"createdAt"] forKey:@"createdAt"];
        [mutablePropertyValues setValue:[representation valueForKey:@"updatedAt"] forKey:@"lastModified"];
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
