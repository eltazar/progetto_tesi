
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

#define TOLLERANCE 20
#define THRESHOLD 0.01
#define MIN_LATITUDE 0.007477
#define MIN_LONGITUDE 0.007677
#define DEFAULT_COORDINATE -180
#define iphoneScaleFactorLatitude   9.0    
#define iphoneScaleFactorLongitude  11.0

@interface MapViewController()
-(void) checkAndAddAnnotation:(NSArray*)annotations;
-(NSInteger)ricercaBinariaNonRicorsiva:(NSArray*)array integer:(NSInteger) x;
-(void)filterAnnotations:(NSArray *)placesToFilter;
@end

@implementation MapViewController 
@synthesize map, publishBtn,toolBar, refreshBtn, bookmarkButtonItem, filterButton, alternativeToolbar, saveJobInPositionBtn, backBtn;


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
        //favouritePinView.image=[UIImage imageNamed:@"favouritePin.png"];
        favouritePinView.pinColor = MKPinAnnotationColorPurple;
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
    //qui devo interrogare il database?? ovvero quando mi sposto di region prendo il centro di questa e in base alle sue coordinate scarico le annotation dal db?
    
    //fare controllo disponibilità connessioen di rete

//    NSLog(@"NUOVA REGION: region.center.latitude %f \n region.center.longitude %f", mapView.region.center.latitude, mapView.region.center.longitude);
//    NSLog    (@"span region latitude: %f ", map.region.span.latitudeDelta);
//    NSLog    (@"span region longitude: %f ", map.region.span.longitudeDelta);

    [dbAccess jobReadRequest:mapView.region field: -1];

    NSLog(@"###########  COUNT MAP PIN = %d",[[map annotations] count]);
}

//per gestire il tap sul disclosure
- (void)mapView:(MKMapView *)_mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    InfoJobViewController *infoJobView = [[InfoJobViewController alloc] initWithJob: view.annotation];
    [self.navigationController pushViewController:infoJobView animated: YES];
    [infoJobView release];
}

#pragma mark - Operazione su MKMapAnnotation

-(void)checkAndAddAnnotation:(NSArray *)annotations
{    
    //NSLog(@"§§§§§§ ANNOTATIONS FROM QUARY = %d, mapANNOTATIONS = %d",annotations.count, [map annotations].count);
    
    NSMutableArray * mapAnnotations = [NSMutableArray arrayWithArray:[map annotations]];
    
    //O(n)
    for(Job *an in [map annotations]){
        if([an isKindOfClass:[MKUserLocation class]] ||
             [an isKindOfClass:[FavouriteAnnotation class]])
            [mapAnnotations removeObject:an];
    }
    
    //NSLog(@"MAP ANNOTATIONS POST DELETING: %d",mapAnnotations.count);
    
    //ordino mapAnnotations, dentro nn c'è user location
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"idDb"
                                                  ascending:YES] autorelease];
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
    
    if(mapAnnotations.count > 1){
        for(int i=0; i<annotationsToAdd.count;i++){
         //   NSLog(@"AN é TIPO: %@",[an class]);
            indexToDelete = [self ricercaBinariaNonRicorsiva:mapAnnotations integer: ((Job*)[annotationsToAdd objectAtIndex:i]).idDb];
            
            if(indexToDelete != -1)
                [indexes addIndex:i];               
        }
        
        [annotationsToAdd removeObjectsAtIndexes:indexes];
    }
   
    NSLog(@"ANNOTATIONS TO ADD POST CHECK: %d",annotationsToAdd.count);
    
    //[map addAnnotations:annotationsToAdd];
    
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
            
            if(((Job*)[array objectAtIndex:m]).idDb == x) 
                return m; // valore x trovato alla posizione m
            else if(((Job*)[array objectAtIndex:m]).idDb < x)
                p = m+1;
            else{
                u = m-1;
            }
        
            //NSLog(@"P = %d ##### U = %d",p,u);

        }
    }
    // se il programma arriva a questo punto vuol dire che 
    // il valore x non è presente in lista, ma se ci fosse
    // dovrebbe trovarsi alla posizione u (nota che qui p > u)
    return -1;
}

-(void)filterAnnotations:(NSArray *)placesToFilter{
        
    float latDelta=map.region.span.latitudeDelta/iphoneScaleFactorLatitude;
    float longDelta=map.region.span.longitudeDelta/iphoneScaleFactorLongitude;
    
    NSMutableArray *jobToShow=[[NSMutableArray alloc] initWithCapacity:0];
    
    for (int i=0; i<[placesToFilter count]; i++) {
        Job *checkingLocation=[placesToFilter objectAtIndex:i];
        CLLocationDegrees latitude = [checkingLocation coordinate].latitude;
        CLLocationDegrees longitude = [checkingLocation coordinate].longitude;
        
        bool found=FALSE;
        for (Job *tempPlacemark in jobToShow) {
            if(fabs([tempPlacemark coordinate].latitude-latitude) < latDelta &&
               fabs([tempPlacemark coordinate].longitude-longitude) <longDelta ){
                [map removeAnnotation:checkingLocation];
                found=TRUE;
                break;
            }
        }
        if (!found) {
            [jobToShow addObject:checkingLocation];
            [map addAnnotation:checkingLocation];
        }
        
    }
    [jobToShow release];
}


#pragma mark - DatabaseAccessDelegate

-(void)didReceiveJobList:(NSArray *)jobList
{
    if(jobList != nil){
        [self checkAndAddAnnotation:jobList];
    }
  //      [self checkAndAddAnnotation:jobList];
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
}

- (void)viewDidLoad
{
    // Do any additional setup after loading the view from its nib.
    [super viewDidLoad];
    
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
    [super dealloc];
}



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}



@end
