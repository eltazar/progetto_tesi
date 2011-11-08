//
//  MKMapView+Region.h
//  jobFinder
//
//  Created by mario greco on 08/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (MKMapView_Region)

- (MKMapRect)mapRectForCoordinateRegion:(MKCoordinateRegion)coordinateRegion;
@end
