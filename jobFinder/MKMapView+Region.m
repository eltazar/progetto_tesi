//
//  MKMapView+Region.m
//  jobFinder
//
//  Created by mario greco on 08/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MKMapView+Region.h"

@implementation MKMapView (MKMapView_Region)


//create a rect from a ragion
- (MKMapRect)mapRectForCoordinateRegion:(MKCoordinateRegion)coordinateRegion
{
    CLLocationCoordinate2D topLeftCoordinate = 
    CLLocationCoordinate2DMake(coordinateRegion.center.latitude 
                               + (coordinateRegion.span.latitudeDelta/2.0), 
                               coordinateRegion.center.longitude 
                               - (coordinateRegion.span.longitudeDelta/2.0));
    
    MKMapPoint topLeftMapPoint = MKMapPointForCoordinate(topLeftCoordinate);
    
    CLLocationCoordinate2D bottomRightCoordinate = 
    CLLocationCoordinate2DMake(coordinateRegion.center.latitude 
                               - (coordinateRegion.span.latitudeDelta/2.0), 
                               coordinateRegion.center.longitude 
                               + (coordinateRegion.span.longitudeDelta/2.0));
    
    MKMapPoint bottomRightMapPoint = MKMapPointForCoordinate(bottomRightCoordinate);
    
    MKMapRect mapRect = MKMapRectMake(topLeftMapPoint.x, 
                                      topLeftMapPoint.y, 
                                      fabs(bottomRightMapPoint.x-topLeftMapPoint.x), 
                                      fabs(bottomRightMapPoint.y-topLeftMapPoint.y));
    
    return mapRect;
}

@end
