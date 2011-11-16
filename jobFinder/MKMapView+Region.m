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

-(int)currentZoomLevel
{
    return round(floor(log2(self.visibleMapRect.size.width / 664.000)));  
}

-(MKMapPoint)centerPointForMapRect:(MKMapRect)mapRect
{
    MKMapPoint center;
    center.x =  mapRect.origin.x + (mapRect.size. width / 2);
    center.y = mapRect.origin.y + (mapRect.size.height / 2);
    
    return center;
}

-(MKMapSize)mapRectSizeForZoom:(float)zoom
{
    
    MKMapSize size;
    size.width = 664 * pow(2, zoom);
    size.height = 844 * pow(2,zoom);
    
    return size;    
}

-(MKMapPoint)rectOriginForCenter:(MKMapPoint)center andSize:(MKMapSize)size
{
    MKMapPoint origin;
    origin.x = center.x - (size.width /2);
    origin.y = center.y - (size.height /2);
    return origin;  
}

@end
