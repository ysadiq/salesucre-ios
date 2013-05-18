//
//  API.h
//  salesucre
//
//  Created by Haitham Reda on 5/17/13.
//  Copyright (c) 2013 Haitham Reda. All rights reserved.
//

#ifndef salesucre_API_h
#define salesucre_API_h

#define kToken @"70da2179f8b4d48b2d652b3b4de2f7e4"

#define kAppStoreID @"523209932"

#define kAPIHostName @"api.olitintl.com"
#define kAPIPostfix @"/APIPlatform/index.php/Version2/"
#define kAPIImagePostfix @"/APIPlatform/index.php/getImage?"
#define KAroundMeDefaultDefinitions @"name,location,address.street,chainId"

// ---- External SDK ---- //
#define kFlurryAPIKey @"KF8RMYTJMX64RSJ2QVRT"


// ---- ParseSDK ---- //
// ---- V1.2.9 ---- //
#define kParseAppId @"73HJhonGfFxg4ZcSP6oY4e1k7OoyP4Xiw0ea2nl4"
#define kParseClientKey @"Oel1DkS3OkT2QNBbeIX2HILmPIwZQyUunrxdmZZ2"
#define kParseRESTAPIKey @"S8gawjiwXYEKIz97FeT5kOKITVLkN1ALqBo8iKJO"
#define kParseMasterKey @"csSbEs9JsQfcP6LiWAk7A71Vuj1BgZJqbEkDNFxo"


// ---- iOS Version Macros ---- //
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define kDefaultLimit 50
#define kDefaultOffset 0
#define KAroundMeDefaultRadius 10

/* MJPopupView animations
 0 "fade in",
 1 "slide - bottom to top",
 2 "slide - bottom to bottom",
 3 "slide - top to top",
 4 "slide - top to bottom",
 5 "slide - left to left",
 6 "slide - left to right",
 7 "slide - right to left",
 8 "slide - right to right",
 */

#define KMJPopupViewAnimation 6
#define kSaleSucreHotline @"19232"


#endif
