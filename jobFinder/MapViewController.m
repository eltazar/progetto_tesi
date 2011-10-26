
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

#define TOLLERANCE 20
#define THRESHOLD 0.01
#define MIN_LATITUDE 0.007477
#define MIN_LONGITUDE 0.007677
#define DEFAULT_COORDINATE -180

@implementation MapViewController 
@synthesize map, publishBtn, infoBtn, toolBar, refreshBtn /*, publishViewCtrl, configView , infoJobView*/;
@synthesize map, publishBtn,toolBar, refreshBtn, bookmarkButtonItem /*, publishViewCtrl, configView , infoJobView*/;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - MKMapViewDelegate

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
        if (annotationView.annotation == mapView.userLocation) {
            //NSLog(@"posizione %f - %f |||| %f %f", mapView.userLocation.coordinate.longitude, mapView.userLocation.coordinate.latitude,map.userLocation.coordinate.longitude,map.userLocation.coordinate.latitude);
            MKCoordinateSpan span = MKCoordinateSpanMake(0.3, 0.3);
            MKCoordinateRegion region = MKCoordinateRegionMake(mapView.userLocation.coordinate, span);
            [mapView setRegion:region animated:YES];
        }
    }
}

//gestisce le annotation durante lo zooming e il panning
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
        pinView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        if(((Job *)annotation).isAnimated)
            pinView.animatesDrop = YES;
        else pinView.animatesDrop = NO;
    }
    else pinView.annotation = annotation;
    
    if([annotation isMultiple])
        pinView.pinColor = MKPinAnnotationColorRed;
    else
        pinView.pinColor = MKPinAnnotationColorGreen;
    //NSLog(@"Annotation: %p -> View: %p", annotation, pinView);
   
    return pinView;
}

- (void)mapView:(MKMapView *)mv didUpdateUserLocation:(MKUserLocation *)userLocation
{
//    CLLocationCoordinate2D userCoordinate = userLocation.location.coordinate;
//
//    for(int i = 1; i<=5;i++)
//    {
//        CGFloat latDelta = rand()*.035/RAND_MAX -.02;
//        CGFloat longDelta = rand()*.03/RAND_MAX -.015;
//        CLLocationCoordinate2D newCoord = { userCoordinate.latitude + latDelta, userCoordinate.longitude + longDelta };
//        JobAnnotation *jobAnn = [[JobAnnotation alloc] initWithCoordinate:newCoord];    
//        [map addAnnotation:jobAnn];
//        [jobAnn release];
//    }    
}


- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    //qui devo interrogare il database?? ovvero quando mi sposto di region prendo il centro di questa e in base alle sue coordinate scarico le annotation dal db?
    NSLog(@"region.center.longitude %f \n region.center.latitude %f", mapView.region.center.longitude, mapView.region.center.latitude);
    NSLog    (@"span region latitude: %f ", map.region.span.latitudeDelta);
    NSLog    (@"span region longitude: %f ", map.region.span.longitudeDelta);

    [self filterAnnotation:arrayJOBtemp];
}

//per gestire il tap sul disclosure
- (void)mapView:(MKMapView *)_mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	// Handle it, such as showing another view controller    
    //BUONO
    
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
    
    
    
    //26 ottobre
    
//    NSLog(@"SENDER = %@",sender);
//    //istanzio la view
//    PublishViewController *publishViewCtrl = [[PublishViewController alloc]initWithStandardRootViewController];
//    
//    //registro la classe come delegato del publishViewController
//    publishViewCtrl.pwDelegate = self;
//    
//    //invio in avanti le user coordinate se ho spinto il bottone "segnala" o c'è stato un long tap
//    if(sender != self)
//        publishViewCtrl.jobCoordinate = map.userLocation.coordinate;
//    else publishViewCtrl.jobCoordinate = coord; //altrimenti setto quelle del tocco
//    
//    //    NSLog(@"USER COORDINATE IN MAPVIEW %f %f",map.userLocation.coordinate.latitude, map.userLocation.coordinate.longitude);
//    
//    //carico la view come vista modale
//    [self presentModalViewController:publishViewCtrl animated:YES];
//    [publishViewCtrl release];
    
}

//inserisce un job in una posizione che non è la userLocation dopo il tap sul tasto SEGNALA
-(IBAction)publishAjob:(id)sender
{
    PublishViewController *publishViewCtrl = [[PublishViewController alloc]initWithStandardRootViewController];
    publishViewCtrl.pwDelegate = self;
    publishViewCtrl.jobCoordinate = jobToPublish.coordinate;
    [jobToPublish release];
    jobToPublish = nil;
    
    [self presentModalViewController:publishViewCtrl animated:YES];
    [publishViewCtrl release];
}

//carica view info nella gerarchia
-(IBAction)infoButtonClicked:(id)sender
{
    
    ConfigViewController *configView = [[ConfigViewController alloc] initWithNibName:@"ConfigViewController" bundle:nil];
    [configView setDelegate:self];
    //animazione e push della view
    [UIView 
     transitionWithView:self.navigationController.view
     duration:1.0
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

#pragma mark - PublishViewControllerDelegate

//dismette la modal view
-(void) dismissPublishView
{
    [self dismissModalViewControllerAnimated:YES];
}


-(void)handleLongPressGesture:(UIGestureRecognizer*)sender 
{
    //Se sto dentro la region minima attivo la possibilità di inserire i job con il tap su map
    if(map.region.span.latitudeDelta <= MIN_LATITUDE && map.region.span.longitudeDelta <= MIN_LONGITUDE){
        // This is important if you only want to receive one tap and hold event
        if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateChanged){
            //[self publishBtnClicked:self coordinate:locCoord];
            return;
        }
        else{
            // Here we get the CGPoint for the touch and convert it to latitude and longitude coordinates to display on the map
            CGPoint point = [sender locationInView:self.map];
            CLLocationCoordinate2D locCoord = [self.map convertPoint:point toCoordinateFromView:self.map];
            
            [self publishBtnClicked:self coordinate:locCoord];
        }
    }
}


/*richiamato dalla view modale dopo il click su inserisci, e gli viene passato il nuovoJob da
 * inviare al db
 */
#warning leggere sotto
-(void)didInsertNewJob:(Job *)newJob
{
    //ricevo il job dalla vista modale già pronto per essere inviato su server
    jobToPublish = [newJob retain]; //fare un retain di newJob e alla fine del metodo un release?   
                                    //così prendo l'ownership di tale oggetto??

//    //debug
//    NSLog(@"************** MAP_VIEW: *************************");
//    NSLog(@"job.employee = %@",jobToPublish.employee);
//    NSLog(@"job.address = %@",jobToPublish.address);
//    NSLog(@"job.description= %@",jobToPublish.description);
//    NSLog(@"job.phone = %@",jobToPublish.phone);
//    NSLog(@"job.email = %@",jobToPublish.email);
//    NSLog(@"job.url = %@",jobToPublish.url);
//    NSLog(@"jobToPublish.coordinate LONG %F | LAT %F",jobToPublish.coordinate.longitude,jobToPublish.coordinate.latitude);
//    NSLog(@"*************************************************");

    //lo aggiungo alla mappa per prova

    [map addAnnotation:jobToPublish];
       
    [self dismissPublishView];  
    [jobToPublish release];
}

//metodo delegate: richiamato dalla view modale dopo il click su annulla
-(void) didCancelNewJob:(PublishViewController *)viewController
{
    [self dismissPublishView];
}

#pragma mark - ConfigViewControllerDelegate
-(void)didSelectedFavouriteZone:(CLLocationCoordinate2D)coordinate
{
    if(favouriteAnnotation != nil){
        [map removeAnnotation:favouriteAnnotation];
    }
//    [favouriteAnnotation release];
//    favouriteAnnotation = nil;
    favouriteAnnotation = [[[FavouriteAnnotation alloc]initWithCoordinate:coordinate] autorelease];
    [map addAnnotation:favouriteAnnotation];
}

#pragma  mark - View lyfe cicle

- (void)viewDidLoad
{
    // Do any additional setup after loading the view from its nib.
    [super viewDidLoad];
    
    //lastSpan = 180/floor( 180/map.region.span.latitudeDelta);
    
    //inizializzazione span
    lastSpan = map.region.span.latitudeDelta;  //ciao
          
    //aggiungo bottone Info alla navigation bar
    UIButton *tempInfoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[tempInfoButton addTarget:self action:@selector(infoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
	
    infoBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tempInfoButton];
	self.navigationItem.leftBarButtonItem = infoBarButtonItem;
    
    //[tempInfoButton release];
    
    //posso passargli un array di jobAnnotation
    //aggiunge un oggetto annotazione al mapView, ma non la vista dell'annotazione
//    [map addAnnotation:[[[JobAnnotation alloc] init] autorelease]];
    
    
    
    longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    [self.map addGestureRecognizer:longPressGesture];
    
    
    //recupero e setto le coordinate preferite all'avvio dell'app
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if([prefs objectForKey: @"lat"] != nil && [prefs objectForKey: @"long"] != nil){
        CLLocationCoordinate2D favouriteCoord = CLLocationCoordinate2DMake([[prefs objectForKey:@"lat"] doubleValue], [[prefs objectForKey:@"long"] doubleValue]);
        //creo ed aggiungo l'annotatione alla mappa
        favouriteAnnotation = [[[FavouriteAnnotation alloc] initWithCoordinate:favouriteCoord] autorelease];
        [map addAnnotation:favouriteAnnotation];   
    }   
    else NSLog(@"STRONZOOOoooooooooooo");
    
    //di default il tasto refresh è disabilitato
    refreshBtn.enabled = NO;
    //########## prove di inserimento jobs
    
    
    //PROVA
    jobDiprova = [[Job alloc] initWithCoordinate:CLLocationCoordinate2DMake(41.485997, 12.606361)];
//    jobDiprova.employee = @"Architettura";
//    jobDiprova.date = @"01/04/2011";
//    jobDiprova.description = @"cercasi architettetto per stage di 5 mesi, rimborso spese 500 euro. Minima esperienza nel settore. Bla bla bla bla bla bla bla bla bla bla bla bla";
////    jobDiprova.phone = @"312347589";
////    jobDiprova.email = @"studioArch@bla.it";
////    jobDiprova.url = @"http://www.ciao.it";
//    jobDiprova.address = @"prova";
    
    
    //array di job di prova
    arrayJOBtemp = [[NSMutableArray alloc] initWithCapacity:1000];
//    for(int i=0;i < 1000; i++){
//        CGFloat latDelta = rand()*.035/RAND_MAX -.02;
//        CGFloat longDelta = rand()*.03/RAND_MAX -.015;
//        CLLocationCoordinate2D newCoord = {37.331693+ latDelta,-122.030457+ longDelta };
//        Job *jobAnn = [[Job alloc] initWithCoordinate:newCoord];
//        jobAnn.employee = [NSString stringWithFormat:@"%d",i];
//        [arrayJOBtemp addObject:jobAnn];
//    }
//    [arrayJOBtemp addObject:jobDiprova];
//    [map addAnnotations:arrayJOBtemp];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - memory management

- (void)dealloc
{
    [favouriteAnnotation release];
    [map release];
    [toolBar release];  
    [refreshBtn release]; 
    [infoBarButtonItem release];
    [publishBtn release];
    [longPressGesture release];
    [super dealloc];
}



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



@end
