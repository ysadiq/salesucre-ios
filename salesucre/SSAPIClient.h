//
//  SSAPIClient.h
//  salesucre
//
//  Created by Haitham Reda on 5/17/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#import <AFRESTClient.h>
#import <AFIncrementalStore.h>
#import <CoreLocation/CoreLocation.h>

// operation blocks
typedef void (^SSAFSuccessBlock)(AFHTTPRequestOperation *operation,id response);
typedef void (^SSAFErrorBlock)(NSError *error);
typedef void (^SSAFResponseArray)(NSMutableArray *responseArray);
typedef void (^SSAFResponseStatusCode)(NSUInteger statusCode);

// response data blocks
typedef void(^XclusivesAFResponseBlock)(id data);


@interface SSAPIClient : AFRESTClient <AFIncrementalStoreHTTPClient>

@property (nonatomic, copy) NSString *language;
@property (nonatomic, assign) int retinaScale;
@property (nonatomic, strong) NSMutableDictionary *timestamps;

+ (id)sharedInstance;

- (NSURL *)imageFullURLFromString:(NSString *)string withWidth:(int)width andHeight:(int)height;
@end
