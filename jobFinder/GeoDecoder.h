//
//  SearchAddress.h
//  jobFinder
//
//  Created by mario greco on 20/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreLocation/CLLocation.h"

@protocol GeoDecoderDelegate;

@interface GeoDecoder : NSObject{
    
    NSMutableData *receivedGeoData;
    NSMutableDictionary *dictionary;
    
    id<GeoDecoderDelegate> delegate;
    
}

@property(nonatomic,readonly) NSMutableDictionary *dictionary;
@property(nonatomic, assign) id<GeoDecoderDelegate> delegate;

-(void) searchCoordinatesForAddress:(NSString *)inAddress;
-(void)searchAddressForCoordinate:(CLLocationCoordinate2D)coordinate;

@end

@protocol GeoDecoderDelegate <NSObject>

-(void)didReceivedGeoDecoderData:(NSDictionary *) geoData;

@end