//
//  FavouriteAnnotation.h
//  jobFinder
//
//  Created by mario greco on 24/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapKit/MapKit.h"

@interface FavouriteAnnotation : NSObject <MKAnnotation>{
    NSString *address;
    CLLocationCoordinate2D _coordinate;
    
    
}
@property (nonatomic, retain) NSString *address;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;


-(id) initWithCoordinate:(CLLocationCoordinate2D) coordinate;

@end