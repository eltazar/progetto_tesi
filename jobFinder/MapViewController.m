
//
//  MapViewController.m
//  jobFinder
//
//  Created by mario greco on 15/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "InfoJobViewController.h"
#import "FavouriteAnnotation.h"
#import "DatabaseAccess.h"
#import "FilterViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MKMapView+Region.h"
#import "GeoDecoder.h"

#define TOLLERANCE 20
#define THRESHOLD 0.01
#define MIN_LATITUDE 0.007477
#define MIN_LONGITUDE 0.007677
#define DEFAULT_COORDINATE -180
#define iphoneScaleFactorLatitude   16.0    
#define iphoneScaleFactorLongitude  20.0
#define ZOOM_THRESHOLD 10 //760567.187974

@interface MapViewController()
@property(nonatomic, assign) int oldZoom;
@property(nonatomic,retain) NSMutableArray *zoomBuffer;
@property(nonatomic,retain) NSMutableArray *annotationsBuffer;
-(void) checkAndAddAnnotation:(NSArray*)annotations;
-(NSInteger)ricercaBinariaNonRicorsiva:(NSArray*)array integer:(NSInteger) x;
//-(void)filterAnnotations:(NSArray *)placesToFilter;
-(void)filterAnnotationsInView:(NSArray*)annotations;
@end

@implementation MapViewController 
@synthesize map, publishBtn,toolBar, refreshBtn, bookmarkButtonItem, filterButton, alternativeToolbar, saveJobInPositionBtn, backBtn, annotationsBuffer, zoomBuffer,oldZoom;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
	
    //NSLog(@"DRAG STATE %d",annotationView.dragState);
    
	if (oldState == MKAnnotationViewDragStateDragging) {
        //NSLog(@"CAMBIO DI STATO: lat = %f , long = %f",annotationView.annotation.coordinate.latitude, annotationView.annotation.coordinate.longitude);
        //NSLog(@"JOBTOPUBLISH CAMBIO STATO: lat = %f, long = %f",jobToPublish.coordinate.latitude,jobToPublish.coordinate.longitude);
	}
}


- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    
    //NSLog(@"METODO USER LOC");
    
    /*attivo il pulsante refresh in base alla user location. Se la localizzazione èdisabilitata dopo un po la userLocation assume i valori di default, quindi disattivol il pulsante.
     */
    if(userLocation.coordinate.latitude != DEFAULT_COORDINATE &&
       userLocation.coordinate.longitude != DEFAULT_COORDINATE){
        refreshBtn.enabled = YES;
    }
    else{
        refreshBtn.enabled = NO;
    }
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    
    
    //zoom sulla posizione dell'utente
    for (MKAnnotationView *annotationView in views) {
        //NSLog(@"annotation view %p",annotationView);
        if (annotationView.annotation == mapView.userLocation) {
            //NSLog(@"posizione %f - %f |||| %f %f", mapView.userLocation.coordinate.longitude, mapView.userLocation.coordinate.latitude,map.userLocation.coordinate.longitude,map.userLocation.coordinate.latitude);
            MKCoordinateSpan span = MKCoordinateSpanMake(0.215664, 0.227966);
            MKCoordinateRegion region = MKCoordinateRegionMake(mapView.userLocation.coordinate, span);
            [mapView setRegion:region animated:YES];
            //NSLog(@"USER LOCATION view %p",annotationView);
        }
        //se il pin è draggabile viene mostrato con il callout già aperto
        if([annotationView.annotation isKindOfClass:[Job class]])
            if(((Job*)annotationView.annotation).isDraggable)
                [mapView selectAnnotation:annotationView.annotation animated:YES];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id )annotation
{    
    //NSLog(@"NUMERO DI ANNOTAZIONI = %d",[map annotations].count);
    
    
    //se la annotation è la nostra posizione, ritorna annotationView standard
    if (annotation == mapView.userLocation) {
        [mapView.userLocation setTitle:@"Mia posizione"];
        return nil;
    }
    
    //se la annotatione è di tipo FavouriteAnnotation la creo e salvo 
    if([annotation isKindOfClass:[FavouriteAnnotation class]]){
        MKPinAnnotationView *favouritePinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"favouritePin"] autorelease];
        favouritePinView.tag = 122;
        favouritePinView.canShowCallout = YES;
        favouritePinView.image=[UIImage imageNamed:@"favorites.png"];
        //favouritePinView.pinColor = MKPinAnnotationColorPurple;
        //NSLog(@"FAVOURITE ANN: %p", favouriteAnnView);
        return favouritePinView;
    }

    //NSString *viewIdentifier = [NSString stringWithFormat:@"%@", ((Job*)annotation).isDraggable?@"YES":@"NO" ];
    
    //NSLog(@"IDENTIFIER = %@",viewIdentifier);
    //se invece la annotation riguarda un lavoro creo e ritorno la vista
    MKPinAnnotationView* pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pin" ];
    
    //se non sono riuscito a riciclare un pin, lo creo
    if(pinView == nil){     
        
        pinView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"]autorelease]; //aggiunto autorelease il 3 novembre
//        NSLog(@"PIN VIEW ALLOCATO: %p",pinView);
        //setto colore, disclosure button ed animazione     
        pinView.canShowCallout = YES;
        pinView.animatesDrop = YES;

    }
    else{ 
//        NSLog(@"PIN VIEW RICICLATO %p  !!!!",pinView);
        pinView.annotation = annotation;
    }

    if(((Job*)annotation).isDraggable){
        
        //NSLog(@" IS DRAGGABLE");
        pinView.rightCalloutAccessoryView = nil;
        [pinView setDraggable:YES];
        pinView.pinColor = MKPinAnnotationColorRed;
    }
    else{
        //NSLog(@"IS NOT DRAGGABLE");
        pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [pinView setDraggable:NO];
        pinView.pinColor = MKPinAnnotationColorGreen; 
    }

    return pinView;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{    
    static int count = 0;
    
    MKMapRect oldRect = [map mapRectForCoordinateRegion:oldRegion];
    MKMapRect newRect = [map mapRectForCoordinateRegion:map.region];
    MKMapRect newExtendedRect = [map mapRectForCoordinateRegion:map.region];  
    
    //ricalcolo il rect dell'attuale region per aumentarne le dimensioni e invio la query
    newExtendedRect.origin.x -= newExtendedRect.size.width / 2;
    newExtendedRect.origin.y -= newExtendedRect.size.height / 2;
    newExtendedRect.size.width *= 2;
    newExtendedRect.size.height *= 2;
    MKCoordinateRegion regionQuery = MKCoordinateRegionForMapRect(newExtendedRect);
    
    //controllo zoom out
    if(newRect.size.width >= oldRect.size.width && [map currentZoomLevel] >= ZOOM_THRESHOLD){
        [dbAccess jobReadRequestOldRegion:oldRegion newRegion:regionQuery field:-1];
    }
    else{
        [dbAccess jobReadRequest:regionQuery field: -1];
    }

    
    oldRegion = mapView.region;
    
    //rimuovo le annotations inserite dopo aver superato un certo zoom in
    NSLog(@"###     annotations buffer = %p, = %d",annotationsBuffer, [annotationsBuffer count]);
    if([mapView currentZoomLevel] >= ZOOM_THRESHOLD && annotationsBuffer != nil){
        [mapView removeAnnotations:annotationsBuffer];
        [annotationsBuffer removeAllObjects];
    }
    
    if([map currentZoomLevel] < 10)
        self.oldZoom = 10;
    
    
    //qui devo interrogare il database?? ovvero quando mi sposto di region prendo il centro di questa e in base alle sue coordinate scarico le annotation dal db?
    
    //fare controllo disponibilità connessioen di rete

    NSLog(@"VISIBLE MAP RECT = w:%f  h:%f, log w = %f", mapView.visibleMapRect.size.width,mapView.visibleMapRect.size.height,log2(mapView.visibleMapRect.size.width / 664.000000));
    NSLog(@"REGION ANNOTATIONS ZOOM = %d", [[mapView annotations] count]);
    
//    NSLog(@"NUOVA REGION: region.center.latitude %f \n region.center.longitude %f", mapView.region.center.latitude, mapView.region.center.longitude);
//    NSLog    (@"span region latitude: %f ", map.region.span.latitudeDelta);
//    NSLog    (@"span region longitude: %f ", map.region.span.longitudeDelta);
//
//    NSLog(@"RECT: w = %f, h = %f",[mapView visibleMapRect].size.width,mapView.visibleMapRect.size.height );
//    
        
    //NSLog(@"visible rect: w = %f, h = %f",mapView.visibleMapRect.size.width,mapView.visibleMapRect.size.height);
    
    /*10-11 novembre*/
    
//    if(count == 0){
//        count++;
//    }
//    else if(count == 1){
//        
//        [dbAccess jobReadRequest:mapView.region field: -1];
//        oldRegion = mapView.region; 
//        count ++;
//    }
//    else if(count == 2){
//        [dbAccess jobReadRequestOldRegion:oldRegion newRegion:mapView.region field:-1]; 
//        MKMapRect oldRect = [map mapRectForCoordinateRegion:oldRegion];
//        MKMapRect newRect = [map mapRectForCoordinateRegion:map.region];
//        if(MKMapRectIsNull( MKMapRectIntersection(oldRect,newRect) ))
//            NSLog(@"NO INTERSEZIONE");
//        else NSLog(@"INTERSEZIONE");        
//        oldRegion = mapView.region; 
//    }

    
    
    //[dbAccess jobReadRequest:mapView.region field: -1];
    
    /*14 novembre*/
//    [dbAccess jobReadRequest:mapView.region field: -1];
//    if(mapView.visibleMapRect.size.width >= MIN_WIDTH && annotationsBuffer != nil)
//        [mapView removeAnnotations:annotationsBuffer];

    
    

//    NSLog(@"###########  COUNT MAP PIN = %d",[[map annotations] count]);
    
    
    
    /*PROVA 14 novembre: questo pezzo di codice è da inserire altrove. non ho bisogno di delegati, singleton ecc per il passaggio dei dati dal filtro al mapviecontroller. basta recuperare dallo user defaults i dati salvati dal filtro.
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSArray *fields = [prefs objectForKey:@"selectedCells"];
    
    if(fields != nil)
        for(NSObject *field in fields)
            NSLog(@"field: %@",field);
     */
}

//per gestire il tap sul disclosure
- (void)mapView:(MKMapView *)_mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    InfoJobViewController *infoJobView = [[InfoJobViewController alloc] initWithJob: view.annotation];
    [self.navigationController pushViewController:infoJobView animated: YES];
    [infoJobView release];
}

#pragma mark - Operazioni su MKMapAnnotation

-(void)updateVisibleAnnotations:(NSArray*)newAnnotations
{
    NSMutableArray *mapAnn = [[NSMutableArray alloc] initWithArray:[map annotations]];
    NSMutableArray *newAnn = [[NSMutableArray alloc] initWithArray:newAnnotations];
    //[annotationsBuffer retain];
    
    for(Job *an in [map annotations]){
        if([an isKindOfClass:[MKUserLocation class]] ||
           [an isKindOfClass:[FavouriteAnnotation class]] || an.isDraggable)
            [mapAnn removeObject:an];
    }
    
    //ordino mapAnnotations, dentro nn c'è user location
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"idDb"
                                                  ascending:NO] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [mapAnn sortUsingDescriptors:sortDescriptors];  
    [newAnn sortUsingDescriptors:sortDescriptors];  
    
    
    for(Job* an in newAnn){

        if([self ricercaBinariaNonRicorsiva:mapAnn integer:((Job*)an).idDb] == -1){
            [map addAnnotation:an];   
            [annotationsBuffer addObject:an];
        }
    }
    
    for(Job* an in mapAnn){
        
        if([self ricercaBinariaNonRicorsiva:newAnn integer:((Job*)an).idDb] == -1){
            [map removeAnnotation:an];
            [annotationsBuffer removeObject:an];
        }        
    }
    
    [mapAnn release];
    [newAnn release];
    //[annotationsBuffer release];
    NSLog(@" PIN SU MAPPA : %d", [[map annotations] count]);
}

-(void)checkAndAddAnnotation:(NSArray *)annotations
{    
    //NSLog(@"§§§§§§ ANNOTATIONS FROM QUARY = %d, mapANNOTATIONS = %d",annotations.count, [map annotations].count);
    
    NSMutableArray * mapAnnotations = [NSMutableArray arrayWithArray:[map annotations]];
    
    //O(n) 
    for(Job *an in [map annotations]){
        if([an isKindOfClass:[MKUserLocation class]] ||
             [an isKindOfClass:[FavouriteAnnotation class]] || an.isDraggable)
            [mapAnnotations removeObject:an];
    }
    
    //NSLog(@"MAP ANNOTATIONS POST DELETING: %d",mapAnnotations.count);
    
    //ordino mapAnnotations per id
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"idDb"
                                                  ascending:NO] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [mapAnnotations sortUsingDescriptors:sortDescriptors];  
    
    
    //#######################
    
    
    //ordino le nuove annotations da valutare per inserimento
    NSMutableArray *annotationsToAdd = [NSMutableArray arrayWithArray:annotations];
        
    [annotationsToAdd sortUsingDescriptors:sortDescriptors];    
    
    
    //###################
    
    NSInteger indexToDelete;
    
    //NSLog(@"ANNOTATIONS: %@",annotationsToAdd);
    NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc]init];

    //NSLog(@"ANNOTATIONS TO ADD PRE CHECK: %d",annotationsToAdd.count);
    
    
    for(int i=0; i<annotationsToAdd.count;i++){
     //   NSLog(@"AN é TIPO: %@",[an class]);
        indexToDelete = [self ricercaBinariaNonRicorsiva:mapAnnotations integer: ((Job*)[annotationsToAdd objectAtIndex:i]).idDb];
        
        if(indexToDelete != -1)
            [indexes addIndex:i];               
    }
    
    
    for(int i=0; i<annotationsToAdd.count;i++){
        //   NSLog(@"AN é TIPO: %@",[an class]);
        indexToDelete = [self ricercaBinariaNonRicorsiva:annotationsBuffer integer: ((Job*)[annotationsToAdd objectAtIndex:i]).idDb];
        
        if(indexToDelete != -1)
            [indexes addIndex:i];               
    }
    
    [annotationsToAdd removeObjectsAtIndexes:indexes];
    
   
    NSSortDescriptor *sortDescriptor2;
    sortDescriptor2 = [[[NSSortDescriptor alloc] initWithKey:@"date"
                                                  ascending:NO selector:@selector(compare:)] autorelease];
    NSArray *sortDescriptors2 = [NSArray arrayWithObject:sortDescriptor2];
    [annotationsToAdd sortUsingDescriptors:sortDescriptors2];  
    
    NSLog(@"ANNOTATIONS TO ADD POST CHECK: %d",annotationsToAdd.count);
    
    //[map addAnnotations:annotationsToAdd];

    //[self filterAnnotationsInView:annotationsToAdd];
    
    //ordino le nuove annotations da valutare per inserimento
    
//    [annotationsToAdd sortUsingDescriptors:sortDescriptors];
//    
//    [annotationsToAdd addObjectsFromArray:mapAnnotations];

    [self filterAnnotations:annotationsToAdd];
    
    [indexes release];

}
-(NSInteger)ricercaBinariaNonRicorsiva:(NSArray*)array integer:(NSInteger) x
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
    // se il programma arriva a questo punto vuol dire che 
    // il valore x non è presente in lista, ma se ci fosse
    // dovrebbe trovarsi alla posizione u (nota che qui p > u)
    return -1;
}

-(void)filterAnnotations:(NSArray *)placesToFilter{
    
    NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc]init];
    float latDelta;//=map.region.span.latitudeDelta/iphoneScaleFactorLatitude;
    float longDelta; //=map.region.span.longitudeDelta/iphoneScaleFactorLongitude;
    MKMapPoint center = [map centerPointForMapRect: [map visibleMapRect]];
    MKCoordinateRegion region;
    MKMapRect rect;
    NSMutableArray *mutablePlacesToFilter = [[NSMutableArray alloc] initWithArray:placesToFilter];
    int zoomLevel = [map currentZoomLevel];
    
    
    NSMutableArray *jobToShow=[[NSMutableArray alloc] initWithCapacity:0];
    
    int cont=0;
   
    if([map currentZoomLevel] > self.oldZoom){
        for(int i=self.oldZoom; i < [map currentZoomLevel]; i++){
            NSLog(@"######## CAZZOOOOOOOOOOO");
            [map removeAnnotations: [zoomBuffer objectAtIndex:(i - ZOOM_THRESHOLD)]];
            [[zoomBuffer objectAtIndex:(i - ZOOM_THRESHOLD)] removeAllObjects];
        }
    }
    
    if([map currentZoomLevel] <= self.oldZoom){
        
        for(int j=self.oldZoom; j>= [map currentZoomLevel];j--){
        
            rect.size = [map mapRectSizeForZoom:j];
            rect.origin = [map rectOriginForCenter:center andSize:rect.size];
            region = MKCoordinateRegionForMapRect(rect);
            
            latDelta = region.span.latitudeDelta / iphoneScaleFactorLatitude;
            longDelta = region.span.longitudeDelta / iphoneScaleFactorLongitude;
            
            for (int i=0; i<[mutablePlacesToFilter count]; i++) {
                Job *checkingLocation=[mutablePlacesToFilter objectAtIndex:i];
                CLLocationDegrees latitude = [checkingLocation coordinate].latitude;
                CLLocationDegrees longitude = [checkingLocation coordinate].longitude;
                
                bool found=FALSE;
                for (Job *tempPlacemark in jobToShow) {
                    if(fabs([tempPlacemark coordinate].latitude-latitude) < latDelta &&
                       fabs([tempPlacemark coordinate].longitude-longitude) <longDelta ){
                        //[map removeAnnotation:checkingLocation];
                        found=TRUE;
                        break;
                    }
                }
                if (!found) {
                    cont++;
                    [jobToShow addObject:checkingLocation];
                    [map addAnnotation:checkingLocation];
                    [[zoomBuffer objectAtIndex:(j - ZOOM_THRESHOLD)] addObject:checkingLocation];
                    [indexes addIndex:i];
                }
                
            }
            NSLog(@" COUNT = %d", cont);
            
            [mutablePlacesToFilter removeObjectsAtIndexes:indexes];
            [indexes removeAllIndexes];
        }
    }
    
//    if([map currentZoomLevel] > oldZoom){
//        for(int i=oldZoom; i < [map currentZoomLevel]; i++){
//            NSLog(@"######## CAZZOOOOOOOOOOO");
//            [map removeAnnotations: [zoomBuffer objectAtIndex:(i - ZOOM_THRESHOLD)]];
//            [[zoomBuffer objectAtIndex:(i - ZOOM_THRESHOLD)] removeAllObjects];
//        }
//    }
    
    self.oldZoom = [map currentZoomLevel];
    
    [mutablePlacesToFilter release];
    [jobToShow release];
}

-(void)filterAnnotationsInView:(NSArray*)annotations
{
    NSMutableSet *newAnnotations = [[NSMutableSet alloc]initWithArray:annotations];
    NSSet *tempMapAnnotations = [map annotationsInMapRect:map.visibleMapRect];
    NSMutableSet *mapAnnotations = [tempMapAnnotations mutableCopy];
    
    for(Job *an in tempMapAnnotations){
        if([an isKindOfClass:[MKUserLocation class]] ||
           [an isKindOfClass:[FavouriteAnnotation class]] || an.isDraggable)
            [mapAnnotations removeObject:an];
    }

    for(Job *an in annotationsBuffer){
        
        if(MKMapRectContainsPoint([map visibleMapRect], MKMapPointForCoordinate(an.coordinate)))
            [newAnnotations addObject:an];
    }
    
    NSMutableArray *totalAnnotations = [[[mapAnnotations setByAddingObjectsFromSet:newAnnotations] allObjects] mutableCopy];
        
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"date"
                                                  ascending:NO selector:@selector(compare:)] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [totalAnnotations sortUsingDescriptors:sortDescriptors];  

    int n = 100;
    int i=0;
    
    for (i=0 ;i<MIN(n,totalAnnotations.count);i++){
        
        if([newAnnotations containsObject:[totalAnnotations objectAtIndex:i]]){
            [map addAnnotation:[totalAnnotations objectAtIndex:i]];
            NSLog(@"AGGIUNTO");
        }
    }
    NSLog(@"### PRIMO FOR i = %d",i);
    for(i=MIN(n,totalAnnotations.count); i<totalAnnotations.count;i++){
        if([mapAnnotations containsObject:[totalAnnotations objectAtIndex:i]]){
            [map removeAnnotation:[totalAnnotations objectAtIndex:i]];
            NSLog(@"TOLTO");
            [annotationsBuffer addObject:[totalAnnotations objectAtIndex:i]];
        }
    }
    
    NSLog(@"### SECONDO FOR i = %d",i);
    
    NSLog(@"ANNOTATIONS IN RECT: %d", [map annotationsInMapRect:[map visibleMapRect]].count);
    
    
    [newAnnotations release];
    [mapAnnotations release];
    [totalAnnotations release];
    
    //per ios<4.2 fare filtraggio di mapAnnotations
    
    
}

#pragma mark - GeoDecodereDelegate

-(void)didReceivedGeoDecoderData:(NSDictionary *)geoData
{
    NSArray *resultsArray = [geoData objectForKey:@"results"];
    NSDictionary *result = [resultsArray objectAtIndex:0];
    CLLocationDegrees latitudeNE = [[[[[result objectForKey:@"geometry"] objectForKey:@"viewport"] objectForKey:@"northeast"] objectForKey:@"lat"] doubleValue];
    CLLocationDegrees longitudeNE = [[[[[result objectForKey:@"geometry"] objectForKey:@"viewport"] objectForKey:@"northeast"] objectForKey:@"lng"] doubleValue];
    CLLocationDegrees latitudeSW = [[[[[result objectForKey:@"geometry"] objectForKey:@"viewport"] objectForKey:@"southwest"] objectForKey:@"lat"] doubleValue];
    CLLocationDegrees longitudeSW = [[[[[result objectForKey:@"geometry"] objectForKey:@"viewport"] objectForKey:@"southwest"] objectForKey:@"lng"] doubleValue];

    CLLocationCoordinate2D regionCenter;
    MKCoordinateSpan regionSpan;
    regionCenter.latitude = (latitudeNE+latitudeSW) / 2;
    regionCenter.longitude = (longitudeNE+longitudeSW) / 2;
    regionSpan.latitudeDelta = fabs(latitudeSW-latitudeNE);
    regionSpan.longitudeDelta = fabs(longitudeNE-longitudeSW);
    
    oldRegion = MKCoordinateRegionMake(regionCenter, regionSpan);
    [map setRegion:oldRegion animated:YES];
}

#pragma mark - DatabaseAccessDelegate

-(void)didReceiveJobList:(NSArray *)jobList
{
    NSLog(@"JOB LIST COUNT = %d",jobList.count);
//    if(jobList != nil){
//        [self updateVisibleAnnotations:jobList];
//    }
    
//    for(Job *j in jobList)
//        NSLog(@" JOB DATE = %@",j.date);
    
    if(jobList != nil){
        if([map currentZoomLevel] >= ZOOM_THRESHOLD)
            [self checkAndAddAnnotation:jobList];
        else [self updateVisibleAnnotations:jobList];
    }
}

-(void)didReceiveResponsFromServer:(NSString *)receivedData
{
    
}

#pragma mark - gestione click bottoni della view

//mostra la action sheet con la scelta del tipo di segnalazione
-(IBAction)publishBtnClicked:(id)sender 
{    

    CLLocationCoordinate2D coordinate;
    
    if(map.userLocation.coordinate.latitude == DEFAULT_COORDINATE && map.userLocation.coordinate.longitude == DEFAULT_COORDINATE){
        
        //mostra avviso che gps spento 
        
        //setta le coordinate del punto draggabile come quelle del centro della region
        coordinate = CLLocationCoordinate2DMake(map.region.center.latitude,map.region.center.longitude);
    }
    else{
        //setta coordinate del punto draggabile come quelle della user location
        coordinate = CLLocationCoordinate2DMake(map.userLocation.coordinate.latitude,map.userLocation.coordinate.longitude);
    }
    
    //alloco il job da pubblicare
    jobToPublish = [[Job alloc] initWithCoordinate:coordinate];
    
    //NSLog(@"JOBTOPUBLISH = %p",jobToPublish);


    if(jobToPublish != nil){
    
        //così il pin sarà draggabile
        jobToPublish.isDraggable = YES;
        //aggiungo annotazione alla mappa
        [map addAnnotation:jobToPublish];
        //segnalo che c'è un pin draggabile sulla mappa
        isDragPinOnMap = YES;
        
        //sposta la vista nella region in cui è stato inserito il pin
        MKCoordinateSpan span = MKCoordinateSpanMake(0.017731, 0.01820);
        MKCoordinateRegion region = MKCoordinateRegionMake(coordinate,span);
        [map setRegion:region animated:YES];
    
            
        /*se è stato inserito un pin draggabile disattivo il tasto segnala ed attio quello per il salvataggio del job nella posizione scelta
         */
        if(isDragPinOnMap){
            publishBtn.enabled = NO;
            saveJobInPositionBtn.enabled = YES;
        }
        
        //carica l'alternativeToolbar con uno slide
        [self.map addSubview:alternativeToolbar];
        alternativeToolbar.frame = CGRectMake(0, self.view.frame.size.height, self.map.frame.size.width,alternativeToolbar.frame.size.height);
        [UIView animateWithDuration:.85 
                         animations:^{
                             alternativeToolbar.frame = CGRectMake(0,map.frame.size.height - alternativeToolbar.frame.size.height , self.map.frame.size.width, alternativeToolbar.frame.size.height);
                         }
         ];
    }

}

//carica la view per la creazione di un job
-(IBAction)saveNewJobInPositionBtnClicked:(id)sender
{
    PublishViewController *publishViewCtrl = [[PublishViewController alloc]initWithStandardRootViewController];
    publishViewCtrl.pwDelegate = self;
    //prima di fare l'istruzione a riga 339 controllare che jobTopublish != nil ???
    publishViewCtrl.newJob = jobToPublish;
    [self presentModalViewController:publishViewCtrl animated:YES];
    [publishViewCtrl release];
}

//carica view info nella gerarchia
-(IBAction)configBtnClicked:(id)sender
{
    
    ConfigViewController *configView = [[ConfigViewController alloc] initWithNibName:@"ConfigViewController" bundle:nil];
    [configView setDelegate:self];
    //animazione e push della view
    [UIView 
     transitionWithView:self.navigationController.view
     duration:0.8
     options:UIViewAnimationOptionTransitionFlipFromRight
     animations:^{ 
         [self.navigationController 
          pushViewController: configView 
          animated:NO];
     }
     completion:NULL];   
    
    [configView release];
}

-(IBAction) showUserLocationButtonClicked:(id)sender
{ 
    if(refreshBtn.enabled){
        //riposiziona la region alla userLocation
        MKCoordinateSpan span = MKCoordinateSpanMake(0.017731, 0.01820);
        MKCoordinateRegion region = MKCoordinateRegionMake(map.userLocation.coordinate, span);
        //    MKCoordinateRegion region = MKCoordinateRegionMake(map.userLocation.coordinate, map.region.span);
        [map setRegion:region animated:YES];
    }
}

-(IBAction)bookmarkBtnClicked:(id)sender
{

//    NSLog(@"BOOKMARKBTN: favourite coord lat : %f",favouriteCoord.latitude);
    if(favouriteAnnotation != nil &&
       favouriteAnnotation.coordinate.latitude != 0 &&
       favouriteAnnotation.coordinate.longitude != 0){
            MKCoordinateSpan span = MKCoordinateSpanMake(0.215664, 0.227966);
            MKCoordinateRegion region = MKCoordinateRegionMake(favouriteAnnotation.coordinate, span);
            [map setRegion:region animated:YES];
    }
}

-(IBAction)backBtnClicked:(id)sender
{
    //fa sparire con uno slide la alternativeToolbar
    CGRect alternativeToolBarFrame = alternativeToolbar.frame;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1];
    alternativeToolBarFrame.origin.y = map.frame.size.height;
    alternativeToolbar.frame = alternativeToolBarFrame;
    [UIView commitAnimations]; 
    

    //rimuovo il pin draggabile dalla mappa
    if(jobToPublish != nil && jobToPublish.isDraggable == YES)
        [map removeAnnotation:jobToPublish];
    
    //segnalo che non ci sono pin draggabili sulla mappa
    isDragPinOnMap = NO;
        
    //riabilito il pulsante segnala
    publishBtn.enabled = YES;
       
    //rilascio jobToPublish istanziato quando si è cliccato su "segnala"
    [jobToPublish release];
    jobToPublish = nil;
}

-(IBAction)filterBtnClicked:(id)sender
{
    FilterViewController *filterTable = [[FilterViewController alloc] initWithPlist:@"filter-table"];    //sectorTable.secDelegate = self;
    [self.navigationController pushViewController:filterTable animated:YES];
    [filterTable release];
}


#pragma mark - PublishViewControllerDelegate

#warning creare array di jobToPublish per non fare leak quando si alloca un nuovo jobToPublish ?????

/*richiamato dalla view modale dopo il click su inserisci. spedisce i dati sul db
 */
-(void)didInsertNewJob:(Job *)newJob
{    
   //segnala che non ci sono pin draggabili sulla mappa
    isDragPinOnMap = NO; 
    //disabilita pulsante per salvare la posizione del job
    saveJobInPositionBtn.enabled = NO;
    //il pin del job segnalato non deve essere più draggabile
    jobToPublish.isDraggable = NO;
    
    
    //INSERIRE CONTROLLO SE INSERIMENTO SU DB è ANDATO A BUON FINE PRIMA DI INSERIRE IL PIN VERDE SULLA MAPPA????
    //richiedo scrittura su db dei dati
    [dbAccess jobWriteRequest:jobToPublish];
    
    //rimuovo il pin rosso e metto quello verde (drag-noDrag)
    if(jobToPublish != nil){
        [map removeAnnotation:jobToPublish];
        [map addAnnotation:jobToPublish];
    }
    
    //fa sparire con uno slide la alternativeToolbar
    CGRect alternativeToolBarFrame = alternativeToolbar.frame;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1];
    alternativeToolBarFrame.origin.y = map.frame.size.height;
    alternativeToolbar.frame = alternativeToolBarFrame;
    [UIView commitAnimations];

    //riattivo pulsante segnalazione
    publishBtn.enabled = YES;

    [self dismissPublishView];  

}

//rimuove il pin rosso dalla mappa se si è scelto di annullare la creazione
-(void) didCancelNewJob:(PublishViewController *)viewController
{
    //se l'operazione di inserimento è annullata il pin draggabile sarà eliminato dalla mappa e rilasciato
    
    [self backBtnClicked:self];

    [self dismissPublishView];
}


//dismette la modal view
-(void) dismissPublishView
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - ConfigViewControllerDelegate

//gestisce il pin relativo all'annotation favourite
-(void)didSelectedFavouriteZone:(CLLocationCoordinate2D)coordinate
{
    //rimuovo la vecchia
    if(favouriteAnnotation != nil){
        [map removeAnnotation:favouriteAnnotation];
    }
    //aggiungo la nuova
    favouriteAnnotation = [[[FavouriteAnnotation alloc]initWithCoordinate:coordinate] autorelease];
    [map addAnnotation:favouriteAnnotation];
}

#pragma  mark - View lyfe cicle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //serve per riabilitare il tasto refreshBtn dopo un memory warnings
    if(map.userLocation.coordinate.latitude != DEFAULT_COORDINATE &&
       map.userLocation.coordinate.longitude != DEFAULT_COORDINATE){
        refreshBtn.enabled = YES;
    }
    else{
        refreshBtn.enabled = NO;
    }
    
    //oldRegion = map.region;
    
}

- (void)viewDidLoad
{
    // Do any additional setup after loading the view from its nib.
    [super viewDidLoad];
    
    self.oldZoom = 18; //max zoom
    oldRegion = MKCoordinateRegionMake(CLLocationCoordinate2DMake(1,2),MKCoordinateSpanMake(0.0000000000001,0.000000000001));
    /**/
    annotationsBuffer = [[NSMutableArray alloc] init];
    zoomBuffer = [[NSMutableArray alloc] initWithCapacity:9];
    for(int i=0;i<9;i++)
        [zoomBuffer insertObject:[[[NSMutableArray alloc]init]autorelease] atIndex:i];    
    /**/
    if(![CLLocationManager locationServicesEnabled] || 
       [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        GeoDecoder *geoDec = [[GeoDecoder alloc]init];
        [geoDec setDelegate:self];
        NSLocale *currentLocale = [NSLocale currentLocale];
        NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
        countryCode = [currentLocale displayNameForKey:NSLocaleCountryCode value:countryCode];
        //NSLog(@"ULOCALE = %@",countryCode);
        [geoDec searchCoordinatesForAddress:countryCode];
        [geoDec release];

    }
    
    /*inizializzazione pulsanti
     */
    //aggiungo bottone Info alla navigation bar
    UIButton *tempInfoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[tempInfoButton addTarget:self action:@selector(configBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    infoBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tempInfoButton];
	self.navigationItem.leftBarButtonItem = infoBarButtonItem;
    
    //tasto refresh è disabilitato di default
    refreshBtn.enabled = NO;
    //tasto publishAlternativeBtn è disabilitato di default
    saveJobInPositionBtn.enabled = NO;
    
    
    /*Inizializzazione proprietà mapView
     */
    lastSpan = map.region.span.latitudeDelta;  //ciao
    //lastSpan = 180/floor( 180/map.region.span.latitudeDelta);
    
    
    /* Inizializzazione valori booleani della classe
     */
    //di default i pin non possono esser "draggati"
    isDragPinOnMap = NO;
    
    /* Gestione delle configurazioni preferite dell'utente
     */
    //recupero e setto le coordinate preferite all'avvio dell'app
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if([prefs objectForKey: @"lat"] != nil && [prefs objectForKey: @"long"] != nil){
        CLLocationCoordinate2D favouriteCoord = CLLocationCoordinate2DMake([[prefs objectForKey:@"lat"] doubleValue], [[prefs objectForKey:@"long"] doubleValue]);
        //creo ed aggiungo l'annotatione alla mappa
        favouriteAnnotation = [[[FavouriteAnnotation alloc] initWithCoordinate:favouriteCoord] autorelease];
//        if([prefs objectForKey:@"address"] != nil)
//            favouriteAnnotation.address = [prefs objectForKey:@"address"];
        [map addAnnotation:favouriteAnnotation];   
        
    } 
    
    /* configurazione pulsanti della view
     */
    saveJobInPositionBtn.layer.cornerRadius = 8;
    saveJobInPositionBtn.layer.borderWidth = 1;
    saveJobInPositionBtn.layer.borderColor = [UIColor grayColor].CGColor;
    saveJobInPositionBtn.clipsToBounds = YES;
    
    backBtn.layer.cornerRadius = 8;
    backBtn.layer.borderWidth = 1;
    backBtn.layer.borderColor = [UIColor grayColor].CGColor;
    backBtn.clipsToBounds = YES;
        
    /* inizializzazione classi necessarie al view controller
     */
    //alloco l'istanza per accesso al db
    dbAccess = [[DatabaseAccess alloc] init];
    [dbAccess setDelegate:self];
    

}

-(double)fRand
{
    double f = ((double)rand()) / RAND_MAX;
    return  f * 2.6e6;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark - memory management

- (void)dealloc
{
    [filterButton release];
    [favouriteAnnotation release];
    [map release];
    [toolBar release];  
    [refreshBtn release]; 
    [infoBarButtonItem release];
    [publishBtn release];
    [dbAccess release];
    [annotationsBuffer release];
    [zoomBuffer release];
    [super dealloc];
}



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}



@end
