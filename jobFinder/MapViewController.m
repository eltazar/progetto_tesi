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
#import "Utilities.h"

#define DEFAULT_COORDINATE -180
#define iphoneScaleFactorLatitude   16.0    
#define iphoneScaleFactorLongitude  20.0
#define ZOOM_THRESHOLD 10 //760567.187974
#define ZOOM_MAX 18
#define EPS 0.00001

#pragma mark - Metodi e ivar private

/*Dichiaro property e metodi privati per il MapViewController
 */
@interface MapViewController()
@property(nonatomic,retain) NSTimer *timer;
@property(nonatomic, retain)NSMutableArray *receivedAnnotations;
@property(nonatomic, assign) int oldZoom;
@property(nonatomic,retain) NSMutableArray *zoomBuffer;
@property(nonatomic,retain) NSMutableArray *annotationsBuffer;
-(void)filterOverThreshold:(NSArray *)newAnnotations;
-(void)filterUnderThreshold:(NSArray*)newAnnotations;
-(void)removeDuplicateAnnotations:(NSMutableArray*)newAnnotations;
-(void)startFiltering;
@end
//end

#pragma mark - Start Implementation

@implementation MapViewController 
//ivar pubbliche
@synthesize map, publishBtn,toolBar, refreshBtn, bookmarkButtonItem, filterButton, alternativeToolbar, saveJobInPositionBtn, backBtn, jobToPublish;
//ivar private
@synthesize annotationsBuffer, zoomBuffer,oldZoom,receivedAnnotations, timer;


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
    /*attivo il pulsante refresh in base alla user location. Se la localizzazione è disabilitata dopo un po la userLocation assume i valori di default, quindi disattivo il pulsante.
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
    
    //mi permette di zoomare sulla posizione dell'utente se gps attivo
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
        favouritePinView.image=[UIImage imageNamed:@"favPin.png"];
        //favouritePinView.pinColor = MKPinAnnotationColorPurple;
        //NSLog(@"FAVOURITE ANN: %p", favouriteAnnView);
        return favouritePinView;
    }
    
    //se invece la annotation riguarda un lavoro creo e ritorno la annotationView dedicata
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
    
    //setto la proprietà draggable
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

//per gestire il tap sul disclosure
- (void)mapView:(MKMapView *)_mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    InfoJobViewController *infoJobView = [[InfoJobViewController alloc] initWithJob: view.annotation];
    [self.navigationController pushViewController:infoJobView animated: YES];
    [infoJobView release];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{   
    //se c'è un pin draggabile sulla mappa non faccio fare letture dal db, risparmio un po di query
    //se c'è internet
    if(!isDragPinOnMap){
            
        static int count = 0;        
        
        if(count == 0)
            ++count;
        else if(count == 1){
            [dbAccess jobReadRequest:mapView.region field: -1];
            ++count;
        }
        else if(count == 2){
            
            //se c'è internet posso fare le query
            if([Utilities networkReachable]){
                
                //calcolo i rect delle regioni
                MKMapRect oldRect = [MKMapView mapRectForCoordinateRegion:oldRegion];
                MKMapRect newRect = [MKMapView mapRectForCoordinateRegion:map.region];
                MKMapRect newExtendedRect = [MKMapView mapRectForCoordinateRegion:map.region];  
                
                //ricalcolo il rect dell'attuale region per aumentarne le dimensioni e fare la query
                newExtendedRect.origin.x -= newExtendedRect.size.width / 2;
                newExtendedRect.origin.y -= newExtendedRect.size.height / 2;
                newExtendedRect.size.width *= 2;
                newExtendedRect.size.height *= 2;
                MKCoordinateRegion regionQuery = MKCoordinateRegionForMapRect(newExtendedRect);
                
                //in base a come effettuo lo zoom cambia il tipo di query
                if(fabs((newRect.size.width - oldRect.size.width)) < EPS && [map currentZoomLevel] >= ZOOM_THRESHOLD){
                    
                    //NSLog(@"PHP 2");
                    [dbAccess jobReadRequestOldRegion:oldRegion newRegion:regionQuery field:-1];
                }
                else{
                    //NSLog(@"PHP 1");
                    [dbAccess jobReadRequest:regionQuery field: -1];
                }
            }
            else{
                //se non c'è internet mostro alert
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Per favore controlla le impostazioni di rete e riprova" message:@"Impossibile collegarsi ad internet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [alert release];
            }
            
            if([map currentZoomLevel] < ZOOM_THRESHOLD)
                self.oldZoom = ZOOM_THRESHOLD-1;
        }
        
        //aggiorno oldRegion con la region attuale
        oldRegion = mapView.region;
    }    
   // NSLog(@"VISIBLE MAP RECT = w:%f  h:%f, log w = %f", mapView.visibleMapRect.size.width,mapView.visibleMapRect.size.height,log2(mapView.visibleMapRect.size.width / 664.000000));

}


#pragma mark - Metodi per filtraggio e fitting delle Annotations

/*rimuove da newAnnotations le annotazioni già presenti sulla mappa
 */
-(void)removeDuplicateAnnotations:(NSMutableArray*)newAnnotations
{
    NSLog(@"\n§§§§§§§§§§§§§§\n§ ANNOTATIONS FROM QUARY = %d, mapANNOTATIONS = %d\n§§§§§§§§§§§§§",newAnnotations.count, [map annotations].count);
    NSMutableArray * mapAnnotations = [map orderedMutableAnnotations];
    
    
    //NSLog(@"MAP ANNOTATIONS POST DELETING: %d",mapAnnotations.count);
    
    //ordino mapAnnotations per id
    //[Job orderJobsByID:newAnnotations];    
    //NSLog(@"ANNOTATIONS: %@",annotationsToAdd);
    
    //elenco indici da eliminare da array
    NSInteger indexToDelete;
    NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc]init];
    
    //NSLog(@"ANNOTATIONS TO ADD PRE CHECK: %d",annotationsToAdd.count);
    
    //cerca tra le annotazioni della mappa quali annotationi di annotatotionsToAdd sono già presenti
    for(int i=0; i<newAnnotations.count;i++){
        //   NSLog(@"AN é TIPO: %@",[an class]);
        indexToDelete = [Job jobBinarySearch:mapAnnotations withID: ((Job*)[newAnnotations objectAtIndex:i]).idDb];
        
        if(indexToDelete != -1)
            [indexes addIndex:i];               
    }
    
    [newAnnotations removeObjectsAtIndexes:indexes];
    NSLog(@"\n -----> ANNOTATIONS TO ADD POST CHECK: %d",newAnnotations.count);
    [indexes release];
}


//calcola quali, tra le annotazioni arrivate dal server, sono quelle da aggiungere alla mappa
-(void)filterUnderThreshold:(NSMutableArray*)newAnnotations
{
    //le annotazioni della mappa ordinate
    NSMutableArray *mapAnn = [map orderedMutableAnnotations];
    
    /* annotationsBuffer contiene tutte le annotations aggiunte superato il livello 10 quando faccio zoom in. Così superato tale livello in zoom out potrò rimuoverle in blocco.
     */
    
    //pulisco lo zoomBuffer se lo zoom scende sotto threshold
    if(self.oldZoom >= ZOOM_THRESHOLD){
        for(NSObject *array in zoomBuffer)
            [(NSMutableArray*)array removeAllObjects];
    }
    
    NSLog(@"\n@@@@@@@@@@@@@@ \n map annotations under pre add: %d \n newAnnotations = %d \n @@@@@@@@@@@@@", [[map annotations]count], [newAnnotations count]);
    
    //rimuovo duplicati che sono tra newAnnotations e mapAnn
    NSMutableArray *newAnnotationNotInMap = [newAnnotations mutableCopy];
    [self removeDuplicateAnnotations:newAnnotationNotInMap];
    [map addAnnotations:newAnnotationNotInMap];
    [annotationsBuffer addObjectsFromArray:newAnnotationNotInMap];
    
    NSLog(@"\n@@@@@@@@@@@@@@ \n map annotations under post add: %d \n newAnnNotInMap = %d\n @@@@@@@@@@@@@", [[map annotations]count],newAnnotationNotInMap.count);
    
    /*fa si che sulla mappa rimangano tutte e sole le annotazioni ritornate dal db (che sono più aggiornate). Di conseguenza se viene superata la soglia di zoom vengono tolte tutte quelle aggiunte dall'altra funzione di filtro
     */
    
    //[Job orderJobsByID:newAnnotations];
    
    for(Job* an in mapAnn){
        if([Job jobBinarySearch:newAnnotations withID:((Job*)an).idDb] == -1){
            [map removeAnnotation:an];
            [annotationsBuffer removeObject:an];
        }        
    }
    NSLog(@"\n@@@@@@@@@@@@@@ \n map annotations under post remv: %d \n @@@@@@@@@@@@@", [[map annotations]count]);
    
    [newAnnotationNotInMap release];
    //[mapAnn release];
}


/* effettua il fitting delle annotations in base al livello di zoom e a dei fattori di scala
 */
-(void)filterOverThreshold:(NSMutableArray *)newAnnotations{
    
    //NSLog(@"\n############# \n@PLACES TO FILTER COUNT = %d\n############", [newAnnotations count]);
    
    NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc]init];
    float latDelta;
    float longDelta; 
    MKMapPoint center = [MKMapView centerPointForMapRect: [map visibleMapRect]];
    MKCoordinateRegion region;
    MKMapRect rect;
    NSMutableArray *mutableNewAnnotations;
    
    
    NSMutableArray *jobToShow=[[NSMutableArray alloc] initWithCapacity:0];
    
    int cont=0;
    
    //############# ZOOM OUT ################
    
    
    //se sto facendo zoom out e il current zoom è >= 10
    if([map currentZoomLevel] > self.oldZoom){
        
        
        //controlla se si è superato il threshold ed elimina tutti i pin inseriti quando si stava sotto il livello threshold
        if(self.oldZoom < ZOOM_THRESHOLD){
            if(annotationsBuffer != nil){
                [map removeAnnotations:annotationsBuffer];
                [annotationsBuffer removeAllObjects];
            }
        }         
        
        //rimuovo per ogni livello di zoom tra 10 e 18 tutti i pin inseriti precendentemente
        for(int i=MAX(ZOOM_THRESHOLD,self.oldZoom); i < [map currentZoomLevel]; i++){
            [map removeAnnotations: [zoomBuffer objectAtIndex:(i - ZOOM_THRESHOLD)]];
            //NSLog(@"\n*********REMOVE********\n*\n zoomBuffer[%d] = %d \n******************* \n * map annotations: %d",i - ZOOM_THRESHOLD,[[zoomBuffer objectAtIndex:i - ZOOM_THRESHOLD] count],[[map annotations]count]);
            [[zoomBuffer objectAtIndex:(i - ZOOM_THRESHOLD)] removeAllObjects];
        }
    }
    
    //############# ZOOM IN ################
    
    //se sto facendo zoom in e il current zoom è >= 10
    //calcola quali sono tra le newAnnotations quelle che sono effettivamente da mostrare
    [self removeDuplicateAnnotations:newAnnotations];
    mutableNewAnnotations = [newAnnotations mutableCopy];
    
    
    //calcola per ogni livello di zoom ed in base al fattore di scala quante annotazioni vanno inserite sulla mappa (fitting)
    for(int j=ZOOM_MAX; j>= [map currentZoomLevel];j--){
        
        rect.size = [MKMapView mapRectSizeForZoom:j];
        rect.origin = [MKMapView rectOriginForCenter:center andSize:rect.size];
        region = MKCoordinateRegionForMapRect(rect);
        
        latDelta = region.span.latitudeDelta / iphoneScaleFactorLatitude;
        longDelta = region.span.longitudeDelta / iphoneScaleFactorLongitude;
        
        for (int i=0; i<[mutableNewAnnotations count]; i++) {
            Job *checkingAnnotation=[mutableNewAnnotations objectAtIndex:i];
            CLLocationDegrees latitude = [checkingAnnotation coordinate].latitude;
            CLLocationDegrees longitude = [checkingAnnotation coordinate].longitude;
            
            bool found=FALSE;
            for (Job *tempPlacemark in jobToShow) {
                if(fabs([tempPlacemark coordinate].latitude-latitude) < latDelta &&
                   fabs([tempPlacemark coordinate].longitude-longitude) <longDelta ){
                    //[map removeAnnotation:checkingLocation];
                    found=TRUE;
                    break;
                }
            }
            if(!found){
                for (Job *tempPlacemark in [map annotations]) {
                    if (![tempPlacemark isKindOfClass:[Job class]] || tempPlacemark.isDraggable)
                        continue;
                    if(fabs([tempPlacemark coordinate].latitude-latitude) < latDelta &&
                       fabs([tempPlacemark coordinate].longitude-longitude) <longDelta ){
                        //[map removeAnnotation:checkingLocation];
                        found=TRUE;
                        break;
                    }
                }
            }
            //solo se non trovo un pin vicino lo aggiungo
            if (!found) {
                cont++;
                [jobToShow addObject:checkingAnnotation];
                [map addAnnotation:checkingAnnotation];
                [[zoomBuffer objectAtIndex:(j - ZOOM_THRESHOLD)] addObject:checkingAnnotation];
                [indexes addIndex:i];
                //NSLog(@"\n*********ADD********\n*\n zoomBuffer[%d] = %d \n*******************\n * map annotations: %d",j - ZOOM_THRESHOLD,[[zoomBuffer objectAtIndex:j - ZOOM_THRESHOLD] count], [[map annotations]count]);
            }
            
        }
        //NSLog(@" COUNT = %d", cont);
        
        [mutableNewAnnotations removeObjectsAtIndexes:indexes];
        [indexes removeAllIndexes];
    }
    //}
    
    //NSLog(@"\n############# \n@MAP ANNS = %d\n############", [[map annotations] count]);
    
    self.oldZoom = [map currentZoomLevel];
        
    [indexes release];
    [mutableNewAnnotations release];
    [jobToShow release];
}


#pragma mark - GeoDecoderDelegate

//all'avvio dell'app setta la region in base alla localizzazione del device utente, se il gps è spento
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

/*riceve una lista di annotazioni e decide quale tipo di filtraggio effettuare in base allo zoom corrente*/
-(void)didReceiveJobList:(NSArray *)jobList
{
    NSLog(@"JOB LIST COUNT = %d",jobList.count);

    //fonde in maniera ordinata le jobList provenienti dal server e le salva in receivedAnnotations
    [Job mergeArray:receivedAnnotations withArray:jobList];
    
    
    NSLog(@"RECEIVED ANNOTATIONS = %d",[receivedAnnotations count]);

    //fa partire un filtro ogni tot secondi
    timer = [NSTimer scheduledTimerWithTimeInterval:0.35 target:self selector:@selector(startFiltering) userInfo:nil repeats:NO];
}

-(void)startFiltering
{
    NSLog(@"--------------------------------------> ENTRATO");
    NSLog(@"---------------------------------------> RECEIVED ANNOTATIONS = %d",[receivedAnnotations count]);
 
    //decide quale filtro utilizzare in base al livello di zoom
    
    if([receivedAnnotations count] != 0){
        if([map currentZoomLevel] >= ZOOM_THRESHOLD) {
            [self filterOverThreshold:receivedAnnotations];
        }
        else [self filterUnderThreshold:receivedAnnotations];
    
    [receivedAnnotations removeAllObjects];
    }    
}

-(void)didReceiveResponsFromServer:(NSString *)receivedData
{
    
    if(![receivedData isEqualToString:@"\"OK\""]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errore connessione" message:@"Non è stato possibile segnalare il lavoro, riprovare" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }
}

#pragma mark - gestione click bottoni della view

//mostra la action sheet con la scelta del tipo di segnalazione
-(IBAction)publishBtnClicked:(id)sender 
{    
    if([Utilities networkReachable]){
        CLLocationCoordinate2D coordinate;
        
        //controllo se gps spento
        if(map.userLocation.coordinate.latitude == DEFAULT_COORDINATE && map.userLocation.coordinate.longitude == DEFAULT_COORDINATE){
            
            //mostra avviso che gps spento 
            
            //setta le coordinate del punto draggabile come quelle del centro della region attuale
            coordinate = CLLocationCoordinate2DMake(map.region.center.latitude,map.region.center.longitude);
        }
        else{
            //setta coordinate del punto draggabile come quelle della user location
            coordinate = CLLocationCoordinate2DMake(map.userLocation.coordinate.latitude,map.userLocation.coordinate.longitude);
        }
        
        //alloco il job da pubblicare
        self.jobToPublish = [[[Job alloc] initWithCoordinate:coordinate] autorelease];
        
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
            
            
            /*se è stato inserito un pin draggabile disattivo il tasto segnala ed attivo quello per il salvataggio del job nella posizione scelta
             */
            if(isDragPinOnMap){
                publishBtn.enabled = NO;
                saveJobInPositionBtn.enabled = YES;
            }
            
            //carica l'alternativeToolbar con uno slide effect
            [self.map addSubview:alternativeToolbar];
            alternativeToolbar.frame = CGRectMake(0, self.view.frame.size.height, self.map.frame.size.width,alternativeToolbar.frame.size.height);
            [UIView animateWithDuration:.85 
                             animations:^{
                                 alternativeToolbar.frame = CGRectMake(0,map.frame.size.height - alternativeToolbar.frame.size.height , self.map.frame.size.width, alternativeToolbar.frame.size.height);
                             }
             ];
        }
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Per favore controlla le impostazioni di rete e riprova" message:@"Impossibile collegarsi ad internet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
        
    }
}

//carica la view per la creazione di un job
-(IBAction)saveNewJobInPositionBtnClicked:(id)sender
{
    PublishViewController *publishViewCtrl = [[PublishViewController alloc]initWithStandardRootViewController];
    publishViewCtrl.pwDelegate = self;
    //passo in avanti il puntatore a jobToPublish
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
        //[map addAnnotation:jobToPublish];
        //faccio partire una query per far caricare il nuovo job sulla mappa
        [dbAccess jobReadRequest:map.region field:-1];
    }
    
    
    //rilascio new job dopo inserimento nel db
//    NSLog(@"DID INSERT JOB RETAIN PRE = %d",[jobToPublish retainCount]);
//    [jobToPublish release];
//    NSLog(@"DID INSERT JOB RETAIN POST = %d",[jobToPublish retainCount]);
//    //jobToPublish = nil;
    
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
    
    //setto il colore del tasto di filtro per segnalare se l'utente ha il filtro su on od off
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if([prefs boolForKey:@"switch"]){
        [filterButton setImage:[UIImage imageNamed:@"filterYellow.png"]];
    }
    else{
        [filterButton setImage:[UIImage imageNamed:@"filterWhite.png"]];
    }
    //oldRegion = map.region;

}

- (void)viewDidLoad
{
    // Do any additional setup after loading the view from its nib.
    [super viewDidLoad];
    
    /*Inizializzazione proprietà mapView
     */
    self.oldZoom = 18; //max zoom
    
    
    /*inizializzo i buffer per lo zoom e per le annotazioni
     */
    //buffer di annotazioni aggiunte sotto la soglia di zoom 10
    annotationsBuffer = [[NSMutableArray alloc] init];
    //buffer composto da nove sotto array che contengono le annotazioni aggiunte ad ogni livello di zoom sopra la soglia 10
    zoomBuffer = [[NSMutableArray alloc] initWithCapacity:9];
    for(int i=0;i<9;i++)
        [zoomBuffer insertObject:[[[NSMutableArray alloc]init]autorelease] atIndex:i];    
    //raccolta di annotazioni aggiunte ad ogni query
    receivedAnnotations = [[NSMutableArray alloc]init];
   
    /* se gps è disattivato interroga servizio per reperire il paese in base al currentLocale dell'utente
     */
    if(![CLLocationManager locationServicesEnabled] || 
       [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
    {
        NSLog(@"CERCO REGIONE");
        GeoDecoder *geoDec = [[GeoDecoder alloc]init];
        [geoDec setDelegate:self];
        NSLocale *currentLocale = [NSLocale currentLocale];
        NSString *countryCode = [currentLocale objectForKey:NSLocaleCountryCode];
        countryCode = [currentLocale displayNameForKey:NSLocaleCountryCode value:countryCode];
        //NSLog(@"ULOCALE = %@",countryCode);
        [geoDec searchCoordinatesForAddress:countryCode];
        [geoDec release];
        
    }
    
    /*inizializzazione pulsanti view
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
    
    [filterButton setImage:[UIImage imageNamed:@"filterWhite.png"]];

    /* Inizializzazione valori booleani per la classe
     */
    //di default i pin non possono esser "draggabili"
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
    [jobToPublish release], jobToPublish = nil;
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
    [receivedAnnotations release];
    [super dealloc];
}



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}



@end
