//
//  SSAPIClient.m
//  salesucre
//
//  Created by Haitham Reda on 5/17/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import "SSAPIClient.h"


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
        [_timestamps setValue:@0 forKey:@"categories"];
        
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
    if ([fetchRequest.entityName isEqualToString:@"XclusivesCategory"]) {
        
        DDLogInfo(@"constructing request");
        //mutableURLRequest = [self requestWithMethod:@"GET" path:@"/api/rest/products" parameters:nil];
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:
                                //                                       kToken, @"oauth_token",
                                _language, @"language",
                                @"gt", @"op",
                                [_timestamps valueForKey:@"categories"] , @"lastModified",
                                @"lastModified", @"opKey",
                                nil];
        
        mutableURLRequest = [self requestWithMethod:@"GET" path:@"categories" parameters:params];
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
    
    if ([entity.name isEqualToString:@"XclusivesCategory"]) {
        DDLogInfo(@"inside entity.name = XclusivesCategory");
        
        //---- change lastModified timestamp ---- //
        if ([[representation valueForKey:@"lastModified"] intValue] > [[_timestamps valueForKey:@"categories"] intValue])
        {
            DDLogInfo(@"new timestamp is higher, assigning new one");
            [_timestamps setValue:[representation valueForKey:@"lastModified"] forKey:@"categories"];
        }
        
        
        //---- end of timestamp ---- //
        
        [mutablePropertyValues setValue:[representation valueForKey:@"_id"] forKey:@"categoryId"];
        [mutablePropertyValues setValue:[representation valueForKey:@"name"] forKey:@"categoryName"];
        
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
        
        
        if ([representation objectForKey:@"images"] && [[representation objectForKey:@"images"] count] > 0 )
        {
            NSDictionary *images = [[representation objectForKey:@"images"] objectAtIndex:0];
            if ([images objectForKeyList:@"path", nil])
            {
                [mutablePropertyValues setValue:[images objectForKeyList:@"path", nil]
                                         forKey:@"imageURL"];
            }
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
