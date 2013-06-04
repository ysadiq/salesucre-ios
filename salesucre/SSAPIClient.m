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

#import <TTTDateTransformers.h>

#define kAPIBaseURL @"http://api.olitintl.com/APIPlatform/index.php/Version2/"
#define kBetaAPIBaseURL @"http://betaapi.olitintl.com/APIPlatform/index.php/Version2/"

#define kAPIHostName @"api.olitintl.com"
#define kBetaAPIHostname @"betaapi.olitintl.com"

#define kHostname kAPIHostName

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
    
    /*
     http://betaapi.olitintl.com/APIPlatform/index.php/getImage?image=/var/www/APIPlatform/files/saleSucre/20060123.jpg&width=640&height=340&crop=640x340+0+0
     */
    
    if (!string || ([string isEqual:[NSNull null]]))
        return nil;
    
    NSString *operationURLString = [NSString
                                    stringWithFormat:@"http://%@%@image=%@&width=%i&height=%i&gravity=center&crop=%dx%d+0+0",kHostname, kAPIImagePostfix ,string,
                                    width * _retinaScale , height * _retinaScale, width * _retinaScale, height * _retinaScale ];
    
    //DDLogInfo(@"current image: %@", operationURLString);
    
    return [NSURL URLWithString:operationURLString];
}

- (NSString *)imagePagerCompatibleString:(NSString *)image withWidth:(int)width andHeight:(int)height
{
    NSString *operationURLString = [NSString
                                    stringWithFormat:@"http://%@%@image=%@&width=%i&height=%i&gravity=center&crop=%dx%d+0+0",kHostname, kAPIImagePostfix ,
                                    image, width * _retinaScale , height * _retinaScale, width * _retinaScale, height * _retinaScale ];
    
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
        
        NSString * time = [NSString stringWithFormat:@"%i",[[_timestamps valueForKey:@"notifications"] intValue] ];
        DDLogInfo(@"timest: %@", time);
        
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                                _language, @"language",
                                @"gt", @"op",
                                time , @"lastModified",
                                @"lastModified", @"opKey",
                                @10, @"limit",
                                nil];
        
        mutableURLRequest = [self requestWithMethod:@"GET" path:@"pushNotifications" parameters:params];
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
#pragma mark - Parsing SSCategory
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
//              [mutablePropertyValues setValue:[[NSValueTransformer valueTransformerForName:TTTISO8601DateTransformerName]
//                                                    transformedValue:createdAtValue ] forKey:@"createdAt"];
                NSTimeInterval timeCreated = (NSTimeInterval)[createdAtValue doubleValue];
                [mutablePropertyValues setValue:[NSDate dateWithTimeIntervalSince1970:timeCreated] forKey:@"createdAt"];
        }
        else
            DDLogWarn(@"????, %@", [createdAtValue class]);
        
//            [mutablePropertyValues setValue:[[NSValueTransformer valueTransformerForName:TTTISO8601DateTransformerName]
//                                                 transformedValue:[representation valueForKey:lastModifiedValue] ] forKey:@"lastModified"];
        
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
        
        [mutablePropertyValues setValue:[NSNumber numberWithInt:[[representation valueForKey:@"weight"] intValue]] forKey:@"weight"];
        
    }
    else if ([entity.name isEqualToString:@"SSMenuItem"])
    {
        #pragma mark - Parsing SSenuItem
        DDLogInfo(@"inside entity.name: %@", entity.name);
        //---- change lastModified timestamp ---- //
        if ([[representation valueForKey:@"lastModified"] intValue] > [[_timestamps valueForKey:@"menuItems"] intValue])
        {
            DDLogInfo(@"new timestamp is higher, assigning new one");
            [_timestamps setValue:[representation valueForKey:@"lastModified"] forKey:@"menuItems"];
        }
        else
        {
            DDLogInfo(@"old timestamp is heigher: %i", [[representation valueForKey:@"lastModified"] intValue]);
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
        
        [mutablePropertyValues setValue:[NSNumber numberWithInt:[[representation valueForKey:@"weight"] intValue]] forKey:@"weight"];
        
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
            DDLogWarn(@"shit! , %@", [createdAtValue class]);
        
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
        #pragma mark - Parsing Images
        DDLogInfo(@"entity.name = %@", entity.name);
        id lastModifiedValue = [[representation valueForKey:@"lastModified"] stringValue];
        
        NSTimeInterval timeModified = (NSTimeInterval)[lastModifiedValue doubleValue];
        [mutablePropertyValues setValue:[NSDate dateWithTimeIntervalSince1970:timeModified] forKey:@"lastModified"];
        
        [mutablePropertyValues setValue:[representation valueForKey:@"label"] forKey:@"label"];
        [mutablePropertyValues setValue:[representation valueForKey:@"path"] forKey:@"path"];
    }
    else if ([entity.name isEqualToString:@"Branch"])
    {
        #pragma mark - Parsing Branch
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
        #pragma mark - Parsing SSNotification
        DDLogInfo(@"entity.name: %@", entity.name);
        
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
        
        //---- change lastModified timestamp ---- //
        if ([lastModifiedValue intValue] > [[_timestamps valueForKey:@"notifications"] intValue])
        {
            DDLogInfo(@"new timestamp is higher, assigning new one");
            [_timestamps setValue:lastModifiedValue forKey:@"notifications"];
        }
        
        // ---- deletedAt ---- //
        @try {
            id deletedAtValue = [[representation valueForKey:@"deletedAt"] stringValue];
            if ( deletedAtValue && ![deletedAtValue isEqual:[NSNull null]] && [deletedAtValue isKindOfClass:[NSString class]] )
            {
                NSTimeInterval timeModified = (NSTimeInterval)[deletedAtValue doubleValue];
                [mutablePropertyValues setValue:[NSDate dateWithTimeIntervalSince1970:timeModified] forKey:@"deletedAt"];
            }

        }
        @catch (NSException *exception) {
            DDLogError(@"exception: %@", exception);
        }
        
        if ([representation objectForKey:@"dataAlertExtend"] != [NSNull null])
        {
            [mutablePropertyValues setValue:[representation valueForKey:@"dataAlertExtend"] forKey:@"dataAlertExtend"];
        }
        
        if ([representation objectForKeyList:@"data",@"alert",nil] != [NSNull null])
        {
            [mutablePropertyValues setValue:[[representation objectForKey:@"data"] valueForKey:@"alert"] forKey:@"alert"];
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
