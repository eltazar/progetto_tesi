
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

#define TOLLERANCE 20
#define THRESHOLD 0.01
#define MIN_LATITUDE 0.007477
#define MIN_LONGITUDE 0.007677
#define DEFAULT_COORDINATE -180

@implementation MapViewController 
@synthesize map, publishBtn,toolBar, refreshBtn, bookmarkButtonItem, filterButton, alternativeToolbar, publishAlternativeBtn, back;


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
	
    NSLog(@"DRAG STATE %d",annotationView.dragState);
    
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
        NSLog(@"annotation view %p",annotationView);
        if (annotationView.annotation == mapView.userLocation) {
            //NSLog(@"posizione %f - %f |||| %f %f", mapView.userLocation.coordinate.longitude, mapView.userLocation.coordinate.latitude,map.userLocation.coordinate.longitude,map.userLocation.coordinate.latitude);
            MKCoordinateSpan span = MKCoordinateSpanMake(0.017731, 0.01820);
            MKCoordinateRegion region = MKCoordinateRegionMake(mapView.userLocation.coordinate, span);
            [mapView setRegion:region animated:YES];
            NSLog(@"USER LOCATION view %p",annotationView);
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id )annotation
{    
    //se la annotation è la nostra posizione, ritorna annotationView standard
    if (annotation == mapView.userLocation) {
        [mapView.userLocation setTitle:@"Mia posizione"];
        return nil;
    }
    
    //se la annotatione è di tipo FavouriteAnnotation la creo e salvo 
    if([annotation isKindOfClass:[FavouriteAnnotation class]]){
        MKAnnotationView *favouritePinView = [[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"favouritePin"] autorelease];
        favouritePinView.tag = 122;
        favouritePinView.canShowCallout = YES;
        favouritePinView.image=[UIImage imageNamed:@"favouritePin.png"];
        //NSLog(@"FAVOURITE ANN: %p", favouriteAnnView);
        return favouritePinView;
    }

    //se invece la annotation riguarda un lavoro creo e ritorno la vista
    MKPinAnnotationView* pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"Pin" ];
    
    //se non sono riuscito a riciclare un pin, lo creo
    if(pinView == nil){     
        
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Pin"];// autorelease];
        //setto colore, disclosure button ed animazione     
        pinView.canShowCallout = YES;
        pinView.animatesDrop = YES;
        

        //        else [pinView setDraggable:NO];
//        if(((Job *)annotation).isAnimated)
//            pinView.animatesDrop = YES;
//        else pinView.animatesDrop = NO;
    }
    else{ 
        NSLog(@"HA RICICLATO %p  !!!!",pinView);
        pinView.annotation = annotation;
    }
    
    if(jobToPublish.isDraggable){
        NSLog(@" IS DRAGGABLE");
        pinView.rightCalloutAccessoryView = nil;
        [pinView setDraggable:YES];
        pinView.pinColor = MKPinAnnotationColorRed;
    }
    else{
        NSLog(@"IS NOT DRAGGABLE");
        pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [pinView setDraggable:NO];
        pinView.pinColor = MKPinAnnotationColorGreen;        
    }

    
    
    
//    if([annotation isMultiple])
//        pinView.pinColor = MKPinAnnotationColorRed;
//    else
//        pinView.pinColor = MKPinAnnotationColorGreen;
    //NSLog(@"Annotation: %p -> View: %p", annotation, pinView); 
    
    return pinView;
}

//- (void)mapView:(MKMapView *)mv didUpdateUserLocation:(MKUserLocation *)userLocation
//{
////    CLLocationCoordinate2D userCoordinate = userLocation.location.coordinate;
////
////    for(int i = 1; i<=5;i++)
////    {
////        CGFloat latDelta = rand()*.035/RAND_MAX -.02;
////        CGFloat longDelta = rand()*.03/RAND_MAX -.015;
////        CLLocationCoordinate2D newCoord = { userCoordinate.latitude + latDelta, userCoordinate.longitude + longDelta };
////        JobAnnotation *jobAnn = [[JobAnnotation alloc] initWithCoordinate:newCoord];    
////        [map addAnnotation:jobAnn];
////        [jobAnn release];
////    }    
//}


- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    //qui devo interrogare il database?? ovvero quando mi sposto di region prendo il centro di questa e in base alle sue coordinate scarico le annotation dal db?
    
    //fare controllo disponibilità connessioen di rete
    
//    NSLog(@"region.center.longitude %f \n region.center.latitude %f", mapView.region.center.longitude, mapView.region.center.latitude);
//    NSLog    (@"span region latitude: %f ", map.region.span.latitudeDelta);
//    NSLog    (@"span region longitude: %f ", map.region.span.longitudeDelta);

    //[self filterAnnotation:arrayJOBtemp];
}

//per gestire il tap sul disclosure
- (void)mapView:(MKMapView *)_mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    InfoJobViewController *infoJobView = [[InfoJobViewController alloc] initWithJob: view.annotation];
    [self.navigationController pushViewController:infoJobView animated: YES];
    [infoJobView release];
}


-(void)filterAnnotation:(NSArray *) annotations
{
    double delta = TOLLERANCE * (map.region.span.latitudeDelta/(self.view.frame.size.width));
    NSMutableArray *annotationInserted = [[[NSMutableArray alloc] init] autorelease];
    NSMutableArray *annotationToRemove = [[[NSMutableArray alloc] init] autorelease];
    

    if(map.region.span.latitudeDelta <= THRESHOLD && lastSpan > THRESHOLD){
        for(Job *ja in annotations)
            ja.isMultiple = FALSE;
        [map removeAnnotations:annotations];
        [map addAnnotations:annotations];        
    }
    
    else{
        
        for( Job *ja in annotations){
        
            ja.isMultiple = FALSE;
            BOOL show = TRUE;
            CGPoint jaPoint = CGPointMake(ja.coordinate.latitude, ja.coordinate.longitude);
            
            for(Job *jai in annotationInserted){
                
                CGRect jaiRect = CGRectMake(jai.coordinate.latitude - delta, jai.coordinate.longitude - delta, 2*delta, 2 * delta);
                if (CGRectContainsPoint(jaiRect, jaPoint)){
                    show = FALSE;
                    if(!jai.isMultiple){
                        jai.isMultiple = TRUE;
                        jai.isAnimated = FALSE;
                        [map removeAnnotation:jai];
                        [map addAnnotation:jai];
                        jai.isAnimated = TRUE;
                    }        
                    [annotationToRemove addObject:ja];
                    break;
                }
                
            }
            
            if(show){
                [annotationInserted addObject:ja];     
            }
        }
        
        [map addAnnotations:annotationInserted];
        [map removeAnnotations:annotationToRemove];
    }
    
    lastSpan = map.region.span.latitudeDelta;
//        
//    NSInteger n = floor( 720/map.region.span.latitudeDelta);
//    
//    float delta = 180/n;
//    
//    double x0 = map.region.center.longitude - (map.region.span.longitudeDelta/2);
//    double y0 = map.region.center.latitude - (map.region.span.latitudeDelta /2);
//    
//    double x1 = floor(x0/delta) * delta;
//    double y1 = floor(y0/delta) * delta;
//    
//    double x = x1;
//    double y = y1;
//    static int count = 0;
//    NSMutableArray * buffer = [[NSMutableArray alloc] initWithCapacity:30];
//    
//    CLLocationCoordinate2D coord;
//    JobAnnotation *ja = [[[JobAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(89,-89)]retain];
////    [buffer addObject:ja];
////    NSLog(@"%p %d", map, ja.retainCount);
////
////    [map addAnnotation:ja];
////       count++;
//    
//    
//    if(delta != lastSpan){
//        [map removeAnnotations:map.annotations];
//        
//        while (x < x1+map.region.span.latitudeDelta + 2*delta) {
//            
//            y = y1;
//            while (y < y1+map.region.span.longitudeDelta + 2*delta) {
//                
//                coord.latitude = y;
//                coord.longitude = x;
//                ja = [[JobAnnotation alloc] initWithCoordinate:coord];
//                [buffer addObject:ja];
//                NSLog(@"Annotation: %p", ja);
//                [map addAnnotation:ja];
//                count++;
//                y += delta;
//                //[ja release];
//            }
//            x += delta;
//        }    
//    }
//    
//    lastSpan = delta;
}

#pragma mark - gestione click bottoni della view

//mostra la action sheet con la scelta del tipo di segnalazione
-(IBAction)showKindOfPublishingJob:(id)sender 
{
        
    UIActionSheet *azione = [[UIActionSheet alloc]initWithTitle:@"Scegli dove segnalare" delegate:self cancelButtonTitle:@"Annulla" destructiveButtonTitle:nil otherButtonTitles:@"Segnala nella tua posizione",@"Segnala altrove", nil];
    azione.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [azione showInView:self.view];
    [azione release];   
}

//inserisce un job in una posizione che non è la userLocation dopo il tap sul tasto SEGNALA
-(IBAction)publishAlternativeBtnClicked:(id)sender
{
    PublishViewController *publishViewCtrl = [[PublishViewController alloc]initWithStandardRootViewController];
    publishViewCtrl.pwDelegate = self;
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
            MKCoordinateSpan span = MKCoordinateSpanMake(0.017731, 0.01820);
            MKCoordinateRegion region = MKCoordinateRegionMake(favouriteAnnotation.coordinate, span);
            [map setRegion:region animated:YES];
    }
}

-(IBAction)backBtnClicked:(id)sender
{
    //setto a NO per far si che sulla view precedente non sia abilitata la segnalazione "ovunque"
    isLongTapEnabled = NO;
    
    if(jobToPublish != nil && jobToPublish.isDraggable == YES)
        [map removeAnnotation:jobToPublish];

    //rilascio jobToPublish istanziato nel metodo handleLongTap
    [jobToPublish release];
    jobToPublish = nil;
    
    [UIView transitionFromView:alternativeToolbar toView:toolBar duration:0.8 options:UIViewAnimationOptionTransitionCurlDown completion:nil];
}

#pragma mark - ActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        //segnalo un job nella userLocation
       
        if(![CLLocationManager locationServicesEnabled] || 
           [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"JobFinder non è in grado di determinare la tua posizione corrente" message:@"Controlla le impostazioni di localizzazione e riprova" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil,nil];
            [alert show];
            [alert release];
        }
        else{
            PublishViewController *publishViewCtrl = [[PublishViewController alloc]initWithStandardRootViewController];
            //registro la classe come delegato del publishViewController
            publishViewCtrl.pwDelegate = self;
            //invio in avanti il jobToPublish
            jobToPublish = [[Job alloc] initWithCoordinate:map.userLocation.coordinate];
            publishViewCtrl.newJob = jobToPublish;
            //    NSLog(@"USER COORDINATE IN MAPVIEW %f %f",map.userLocation.coordinate.latitude, map.userLocation.coordinate.longitude);
            //carico la view come vista modale
            [self presentModalViewController:publishViewCtrl animated:YES];
            [publishViewCtrl release];
        }
    } 
    else if (buttonIndex == 1) {
        //segnala job altrove, modifica la vista mostrando una view con un help ed un button
        
        //abilita il long tap per segnalare ovunque sulla mappa
        isLongTapEnabled = YES;
        //appena caricata la vista non c'è nessun pin draggabile sulla mappa
        isDragPinOnMap = NO;
        [UIView transitionFromView:toolBar toView:alternativeToolbar duration:0.8 options:UIViewAnimationOptionTransitionCurlUp completion:nil];
    }
    else if (buttonIndex == 2) {
        //annulla
    }
    
}

#pragma mark - PublishViewControllerDelegate

-(void)handleLongPressGesture:(UIGestureRecognizer*)sender 
{
    //se non c'è un altro pin draggabile sulla mappa e se la funzione è abilitata
    if(!isDragPinOnMap && isLongTapEnabled){
        // This is important if you only want to receive one tap and hold event
        if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateChanged){
                return;
        }
        else{
            // Here we get the CGPoint for the touch and convert it to latitude and longitude coordinates to display on the map
            CGPoint point = [sender locationInView:self.map];
            CLLocationCoordinate2D locCoord = [self.map convertPoint:point toCoordinateFromView:self.map];
            jobToPublish = [[Job alloc]initWithCoordinate:locCoord];
            NSLog(@"JOB TO PUBLISH LONG TAP %p",jobToPublish);
            //così il pin sarà draggabile
            jobToPublish.isDraggable = YES;
            //ora c'è un pin draggabile sulla mappa
            isDragPinOnMap = YES;
            [map addAnnotation:jobToPublish];
            //abilito tasto per la segnalazione
            publishAlternativeBtn.enabled = YES;
        }
   }
    
}


/*richiamato dalla view modale dopo il click su inserisci. spedisce i dati sul db
 */
-(void)didInsertNewJob:(Job *)newJob
{    
    //segnala che non ci sono pin draggabili sulla mappa
    isDragPinOnMap = NO;
    //disabilita pulsante per segnalazione alternativa
    publishAlternativeBtn.enabled = NO;
    //il pin del job segnalato non deve essere più draggabile
    jobToPublish.isDraggable = NO;
    //richiedo scrittura su db dei dati
    [dbAccess jobWriteRequest:jobToPublish];
    
    //rimuovo il pin rosso e metto quello verde (drag-noDrag)
    if(jobToPublish != nil){
        [map removeAnnotation:jobToPublish];
        [map addAnnotation:jobToPublish];
    }
    
    [self dismissPublishView];  

}

//metodo delegate: richiamato dalla view modale dopo il click su annulla
-(void) didCancelNewJob:(PublishViewController *)viewController
{
    //se l'operazione di inserimento è annullata il pin è ancora draggabile
    isDragPinOnMap = YES;
    publishAlternativeBtn.enabled = YES;
    
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
    //tasto publish è disabilitato di default
    //publishBtn.enabled = NO;
    //tasto publishAlternativeBtn è disabilitato di default
    publishAlternativeBtn.enabled = NO;
    
    
    /*Inizializzazione frame delle sotto viste
     */
    //setto il frame dell'alternativeToolbar, posizione bottom
    CGRect a = CGRectMake(alternativeToolbar.frame.origin.x, self.view.frame.size.height-toolBar.frame.size.height-5,alternativeToolbar.frame.size.width,alternativeToolbar.frame.size.height);
    [alternativeToolbar setFrame:a];
    
    /* Inizializzazione del gesture recognizer
     */
    longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self.map addGestureRecognizer:longPressGesture];
    
    
    
    /*Inizializzazione proprietà mapView
     */
    lastSpan = map.region.span.latitudeDelta;  //ciao
    //lastSpan = 180/floor( 180/map.region.span.latitudeDelta);

    
    /* Inizializzazione valori booleani della classe
     */
    //di default i pin non possono esser "draggati"
    isDragPinOnMap = NO;
    isLongTapEnabled = NO;
    
    /* Gestione delle configurazioni preferite dell'utente
     */
    //recupero e setto le coordinate preferite all'avvio dell'app
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if([prefs objectForKey: @"lat"] != nil && [prefs objectForKey: @"long"] != nil){
        CLLocationCoordinate2D favouriteCoord = CLLocationCoordinate2DMake([[prefs objectForKey:@"lat"] doubleValue], [[prefs objectForKey:@"long"] doubleValue]);
        //creo ed aggiungo l'annotatione alla mappa
        favouriteAnnotation = [[[FavouriteAnnotation alloc] initWithCoordinate:favouriteCoord] autorelease];
        [map addAnnotation:favouriteAnnotation];   
        
    } 
    
    /* inizializzazione classi necessarie al view controller
     */
    //alloco l'istanza per accesso al db
    dbAccess = [[DatabaseAccess alloc] init];


    
    /**** PROVE DA CANCELLARE ****/
   
    //posso passargli un array di jobAnnotation
    //aggiunge un oggetto annotazione al mapView, ma non la vista dell'annotazione
//    [map addAnnotation:[[[JobAnnotation alloc] init] autorelease]];
    
    //########## prove di inserimento jobs
    
    
    //PROVA
//    jobDiprova = [[Job alloc] initWithCoordinate:CLLocationCoordinate2DMake(41.485997, 12.606361)];
//    jobDiprova.employee = @"Architettura";
//    jobDiprova.date = @"01/04/2011";
//    jobDiprova.description = @"cercasi architettetto per stage di 5 mesi, rimborso spese 500 euro. Minima esperienza nel settore. Bla bla bla bla bla bla bla bla bla bla bla bla";
////    jobDiprova.phone = @"312347589";
////    jobDiprova.email = @"studioArch@bla.it";
////    jobDiprova.url = @"http://www.ciao.it";
//    jobDiprova.address = @"prova";

    
//    NSString *template = @"(NULL ,  '%@',  '%@',  NULL, NULL,  '%@',  '%f',  '%f',  '%d'),";
//    
//    //array di job di prova
//    arrayJOBtemp = [[NSMutableArray alloc] initWithCapacity:500];
//    
//    NSDateFormatter* formatter = [[[NSDateFormatter alloc] init] autorelease];
//    [formatter setDateFormat:@"yyyy-MM-dd"];
//    
//
//    NSMutableString *superQuery = [[NSMutableString alloc]initWithFormat:@"%@",@"INSERT INTO  `my_jobfinder`.`job` (`id` ,`description` ,`phone` ,`email` ,`url` ,`date` ,`latitude` ,`longitude` ,`field`)VALUES"];
//    
//    for(int i=0;i < 500; i++){
//        
//        
//        CGFloat latDelta = rand()*.11/RAND_MAX -.02;
//        CGFloat longDelta = rand()*.11/RAND_MAX -.015;
//        CLLocationCoordinate2D newCoord = {41.891672+ latDelta,12.493515+ longDelta };
//        Job *jobAnn = [[Job alloc] initWithCoordinate:newCoord];
//        jobAnn.employee = [NSString stringWithFormat:@"%d",i];
//        jobAnn.description = @"bla";
//        jobAnn.phone = @"1234";
//        jobAnn.date = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:[self fRand]]];
//        NSLog(@"DATaaaa ############ %@",jobAnn.date);
//        [arrayJOBtemp addObject:jobAnn];
//        NSMutableString *query = [[NSString alloc] initWithFormat:template,jobAnn.description, jobAnn.phone,jobAnn.date,jobAnn.coordinate.latitude,jobAnn.coordinate.longitude,i];
//        [superQuery appendString:query];
//
//    }
//    [superQuery replaceCharactersInRange: NSMakeRange(superQuery.length-1,1) withString:@";"];
//    NSLog(superQuery);
    
    
//    [arrayJOBtemp addObject:jobDiprova];
//    [map addAnnotations:arrayJOBtemp];

}

-(IBAction)filterBtnClicked:(id)sender
{
    NSLog(@"CIAOOOOOOOOOOOOOOOO");
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
    [longPressGesture release];
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
