//
//  PublishViewController.m
//  jobFinder
//
//  Created by mario greco on 30/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PublishViewController.h"
#import "EditJobViewController.h"
#import "MapKit/MKAnnotation.h"
#import "Reachability.h"

@implementation PublishViewController
@synthesize pwDelegate, jobCoordinate, addressGeocoding, newJob;



- (id) initWithStandardRootViewController
{    
    tableView = [[EditJobViewController alloc] initWithNibName:@"RootJobViewController" bundle:nil]; //autorelease?
    
    self = [super initWithRootViewController:tableView];
    
    if(self)
    {
        self.newJob = nil;
    }
    
    return self;
}

#pragma mark - metodi bottoni della view

-(IBAction)insertBtnPressed:(id)sender
{   
    //fa si che il testo inserito nei texfield sia preso anche se non è stata dismessa la keyboard
    [self.view endEditing:TRUE];

    //setto data creazione annuncio
    NSLocale *locale = [NSLocale currentLocale];
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease]; 
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:@"E MMM d yyyy" options:0 locale:locale];
    [formatter setDateFormat:dateFormat];
    [formatter setLocale:locale];
    newJob.date = [formatter stringFromDate:[NSDate date]];
       
    //controllo la validità dei campi inseriti
    if([self validate:newJob]){    
        //controllo stato connessione
        Reachability *internetReach = [[Reachability reachabilityForInternetConnection] retain];
        [internetReach startNotifier];
        NetworkStatus netStatus = [internetReach currentReachabilityStatus];
        
        if(netStatus == 0){
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Per favore controlla le impostazioni di rete e riprova" message:@"Impossibile collegarsi ad internet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [alert release];
        }
        else    [pwDelegate didInsertNewJob:newJob]; //passo al delegato il nuovo job;
        
        [internetReach release]; //aggiunto autorelease il 3 novembre
    }
    
    //[newJob release];
}

-(IBAction)cancelBtnPressed:(id)sender{
    
    //dico al delegato che è stato spinto annulla
    [self.pwDelegate didCancelNewJob:self];
}

-(void)activeInsertBtn:(id)sender
{
    //abilita il tasto inserisci se è stato scelto il settore
    tableView.navigationItem.rightBarButtonItem.enabled = YES;
}


#warning spostare nella logica??
-(BOOL)validate:(Job*) job
{
    BOOL rtn = YES; 
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //passo il newJob alla tabella per esser riempito
    ((EditJobViewController *) tableView).job = self.newJob;
    //NSLog(@"WILL: NEW JOB PUNTA A: %p", newJob);
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
     
    // NSLog(@"VIEWLoad user coordinate %f %f",userCoordinate.latitude,userCoordinate.longitude);    
    
    //setto la navigationBar
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.translucent = YES;
    tableView.navigationItem.title = @"Inserisci";
    
    //aggiungo bottone "inserisci" ed "annulla" alla barra
    UIBarButtonItem *insertButton = [[UIBarButtonItem alloc] initWithTitle:@"Inserisci" style:UIBarButtonItemStylePlain target:self action:@selector(insertBtnPressed:)];          
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Annulla" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtnPressed:)];     
    tableView.navigationItem.rightBarButtonItem = insertButton;
    tableView.navigationItem.leftBarButtonItem = cancelButton;
    
    //di default insertButton è disabilitato
    insertButton.enabled = NO;
    
    //attende il segnale di avvenuta selezione di un settore di lavoro per far attivare il tasto "inserisci"
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
    [tableView release];
    [super dealloc];
}

@end
