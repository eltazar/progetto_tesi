//
//  MKMapView+Region.m
//  jobFinder
//
//  Created by mario greco on 08/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MKMapView+Utils.h"
#import "Job.h"
#import "FavouriteAnnotation.h"

@implementation MKMapView (MKMapView_Utils)


//crea un rect data una region
+ (MKMapRect)mapRectForCoordinateRegion:(MKCoordinateRegion)coordinateRegion
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

//calcola il livello di zoom corrente, dopo averlo discretizzato e normalizzato
-(int)currentZoomLevel
{
    return round(floor(log2(self.visibleMapRect.size.width / 664.000)));  
}

//calcola il centro di un rect
+(MKMapPoint)centerPointForMapRect:(MKMapRect)mapRect
{
    MKMapPoint center;
    center.x =  mapRect.origin.x + (mapRect.size. width / 2);
    center.y = mapRect.origin.y + (mapRect.size.height / 2);
    
    return center;
}

//calcola il size di un rect in base al livello di zoom
+(MKMapSize)mapRectSizeForZoom:(float)zoom
{
    
    MKMapSize size;
    size.width = 664 * pow(2, zoom);
    size.height = 844 * pow(2,zoom);
    
    return size;    
}

//ritorna il punto di origin per un rect dato il centro e il size del rect
+(MKMapPoint)rectOriginForCenter:(MKMapPoint)center andSize:(MKMapSize)size
{
    MKMapPoint origin;
    origin.x = center.x - (size.width /2);
    origin.y = center.y - (size.height /2);
    return origin;  
}

-(NSMutableArray*) jobAnnotations {
    //NSMutableArray *jAnnotations = [[[NSMutableArray alloc] initWithArray:[self annotations]]autorelease];
    NSMutableArray *jAnnotations = [[[self annotations] mutableCopy]autorelease];
    for(Job *an in [self annotations]){
        if(![an isKindOfClass:[Job class]] || an.isDraggable)
            [jAnnotations removeObject:an];
    }
    return jAnnotations;
}

-(NSMutableArray*) orderedMutableAnnotations {
    
    NSMutableArray *omAnnotations = [self jobAnnotations];
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"idDb"
                                                  ascending:NO] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [omAnnotations sortUsingDescriptors:sortDescriptors]; 
    
    return omAnnotations;
}

@end
