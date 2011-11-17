//
//  MKMapView+Region.m
//  jobFinder
//
//  Created by mario greco on 08/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MKMapView+Region.h"
#import "Job.h"
#import "FavouriteAnnotation.h"

@implementation MKMapView (MKMapView_Region)


//crea un rect data una region
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

//calcola il livello di zoom corrente, dopo averlo discretizzato e normalizzato
-(int)currentZoomLevel
{
    return round(floor(log2(self.visibleMapRect.size.width / 664.000)));  
}

//calcola il centro di un rect
-(MKMapPoint)centerPointForMapRect:(MKMapRect)mapRect
{
    MKMapPoint center;
    center.x =  mapRect.origin.x + (mapRect.size. width / 2);
    center.y = mapRect.origin.y + (mapRect.size.height / 2);
    
    return center;
}

//calcola il size di un rect in base al livello di zoom
-(MKMapSize)mapRectSizeForZoom:(float)zoom
{
    
    MKMapSize size;
    size.width = 664 * pow(2, zoom);
    size.height = 844 * pow(2,zoom);
    
    return size;    
}

//ritorna il punto di origin per un rect dato il centro e il size del rect
-(MKMapPoint)rectOriginForCenter:(MKMapPoint)center andSize:(MKMapSize)size
{
    MKMapPoint origin;
    origin.x = center.x - (size.width /2);
    origin.y = center.y - (size.height /2);
    return origin;  
}

//effettua la ricerca binaria su un array di un dato un idDb di un'annotation
-(NSInteger)binarySearch:(NSArray*)array integer:(NSInteger) x
{   
    //    NSLog(@"RICERCA BINARIA; ARRAY COUNT = %d",array.count);
    //NSLog(@"X = %d",x);
    NSInteger p;
    NSInteger u;
    NSInteger m;
    p = 0;
    u = [array count] - 1;
    //    NSLog(@"U = %d",u);
    while(p <= u) {
        m = (p+u)/2;
        //NSLog(@"M = %d",m);
        if(!([((Job*)[array objectAtIndex:m]) isKindOfClass:[MKUserLocation class]] ||
             [((Job*)[array objectAtIndex:m]) isKindOfClass:[FavouriteAnnotation class]])){
            
            //NSLog(@"M.IDDB = %d",((Job*)[array objectAtIndex:m]).idDb);
            
            if(((Job*)[array objectAtIndex:m]).idDb == x){ 
                //NSLog(@"TROVATO");
                return m; // valore x trovato alla posizione m
            }
            else if(((Job*)[array objectAtIndex:m]).idDb > x)
                p = m+1;
            else{
                u = m-1;
            }
            
            //NSLog(@"P = %d ##### U = %d",p,u);
            
        }
    }
    
    //NSLog(@"NON TROVATO");
    return -1;
}


@end
