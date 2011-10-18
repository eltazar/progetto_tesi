//
//  PublishViewController.m
//  jobFinder
//
//  Created by mario greco on 30/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PublishViewController.h"
#import "EditJobViewController.h"
#import "MapKit/MKReverseGeocoder.h"
#import "MapKit/MKAnnotation.h"

@implementation PublishViewController
@synthesize pwDelegate, jobCoordinate, addressGeocoding;



- (id) initWithStandardRootViewController
{    
    tableView = [[EditJobViewController alloc] initWithNibName:@"RootJobViewController" bundle:nil]; //autorelease?
    
    self = [super initWithRootViewController:tableView];
    
    if(self)
    {
    }
    
    return self;
}


#pragma mark - MKReverseGeocoderDelegate

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark
{
        NSLog(@"#######################SONO IN REVERSE GEOCODING");
    if(placemark.thoroughfare == nil){
        self.addressGeocoding = @"Indirizzo non disponibile";
        return;
    }
    NSString *first = [NSString stringWithFormat:@"%@",placemark.thoroughfare];
    NSString *second;
    
    if(placemark.subThoroughfare == nil)
        second = @"";
    else second = [NSString stringWithFormat:@", %@",placemark.subThoroughfare];
    
    self.addressGeocoding = [NSString stringWithFormat:@"%@%@",first,second];
        NSLog(@"address = %@", self.addressGeocoding);
    //    NSLog(@"new job %p",newJob);
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
    NSLog(@"Reverse Geocoding Fallito");
    self.addressGeocoding = @"FALLITO";
}

#pragma mark - metodi bottoni della view

-(IBAction)insertBtnPressed:(id)sender
{   
    //fa si che il testo inserito nei texfield sia preso anche se non è stata dismessa la keyboard
    [self.view endEditing:TRUE];
#warning 
    //ricavo il job dalla tabella
    newJob = [((EditJobViewController *) tableView).job retain];  //???retain???
    newJob.coordinate =  CLLocationCoordinate2DMake(jobCoordinate.latitude,jobCoordinate.longitude);
   
    
    //setto indirizzo dopo il reverseGeocoding
    newJob.address = self.addressGeocoding;
    
    //setto data creazione annuncio
    NSLocale *locale = [NSLocale currentLocale];
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease]; 
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"E MMM d yyyy" options:0 locale:locale];
    [formatter setDateFormat:dateFormat];
    [formatter setLocale:locale];
    newJob.date = [formatter stringFromDate:[NSDate date]];
    
    
    
    //    NSLog(@"New Job retain count = %p",newJob);
    //    NSLog(@"job retain count = %p",((EditJobViewController *) tableView).job);
    
    //    NSLog(@"************* PublishViewController************");    
    //    NSLog(@"user coordinate %f %f",userCoordinate.latitude,userCoordinate.longitude);    
    //    NSLog(@"newJob = %p |||| newJob.coordinate LONG %F | LAT %F",newJob, newJob.coordinate.longitude,newJob.coordinate.latitude);
    //    NSLog(@"job.employee = %@",newJob.employee);
    //    NSLog(@"***********************************************");    
    
    //VEDERE IL PROB DELLA MEMORIA DI QUESTI TIPI DI OGGETTI
    
    
    
    if([self validate:newJob]){    
        //passo al delegato il nuovo job;
        [pwDelegate receiveAnewJob:newJob];
    }
    
    [newJob release];
}

-(IBAction)cancelBtnPressed:(id)sender{
    
    //dico al delegato che è stato spinto annulla
    [self.pwDelegate publishViewControllerDidCancel:self];
}

-(void)activeInsertBtn:(id)sender
{
    tableView.navigationItem.rightBarButtonItem.enabled = YES;
}


#warning spostare nella logica??
-(BOOL)validate:(Job*) job
{
    BOOL rtn = YES; 

    //job.phone rimuovere spazi, - , /, tutto ciò che non è un numero
    //job.url inserire http:// davanti ad indirizzi che non lo hanno
    
//    // validate email address
//    NSString* emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"; 
//    NSPredicate* emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
//    
//    if(!([newJob.email isEqualToString:@""] || newJob.email == nil))
//        rtn = [emailTest evaluateWithObject:newJob.email];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    rtn = [job isValid];
    
    if (!rtn){
        NSString *message = [NSString stringWithFormat:@"%@ formalmente \n non valido",[job invalidReason]];
        [alert setMessage:NSLocalizedString(message, @"")];
        [alert show];		
    }

    [alert release];

    
    return rtn;
}

#pragma mark - View lifecycle

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    reverseGecoder = [[MKReverseGeocoder alloc]initWithCoordinate:jobCoordinate];
    reverseGecoder.delegate = self;
    [reverseGecoder start]; //attivare quando necessario sennò google si incazza
    
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    // NSLog(@"VIEWLoad user coordinate %f %f",userCoordinate.latitude,userCoordinate.longitude);    
    
    //setto la naviationBar
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.translucent = YES;
    tableView.navigationItem.title = @"Inserisci";
    
    //aggiungo bottone "inserisci" ed "annulla" alla barra
    UIBarButtonItem *insertButton = [[UIBarButtonItem alloc] initWithTitle:@"Inserisci" style:UIBarButtonItemStylePlain target:self action:@selector(insertBtnPressed:)];          
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Annulla" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtnPressed:)];     
    tableView.navigationItem.rightBarButtonItem = insertButton;
    tableView.navigationItem.leftBarButtonItem = cancelButton;
    
    insertButton.enabled = NO;
    
    //attende il segnale di avvenuta selezione di una categoria di lavoro per far attivare il tasto "inserisci"
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activeInsertBtn:) name:@"employeeDidSet" object:nil];
    
    [insertButton release];
    [cancelButton release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - memory management
-(void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void) dealloc
{
    //per ora li metto ma non so se è giusto
    //    [newJob release];
    //[tableView release];
    //    [pwDelegate release];
    [super dealloc];
    [tableView release];
    [reverseGecoder release];
}

@end
