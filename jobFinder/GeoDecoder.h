//
//  SearchAddress.h
//  jobFinder
//
//  Created by mario greco on 20/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeoDecoder : NSObject{
    
    NSMutableData *receivedGeoData;
    NSMutableDictionary *dictionary;
    
}

@property(nonatomic,readonly) NSMutableDictionary *dictionary;

+(void) searchCoordinatesForAddress:(NSString *)inAddress;






@end