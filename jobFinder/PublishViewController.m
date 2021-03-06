//
//  PublishViewController.m
//  jobFinder
//
//  Created by mario greco on 30/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PublishViewController.h"
#import "EditJobViewController.h"
#import "ModJobViewController.h"
#import "MapKit/MKAnnotation.h"
#import "Utilities.h"

@implementation PublishViewController
@synthesize pwDelegate, jobCoordinate, addressGeocoding, theNewJob;


//istanzia tableView per creare nuova offerta di lavoro
- (id) initWithStandardRootViewController
{    
    tableView = [[EditJobViewController alloc] initWithNibName:@"RootJobViewController" bundle:nil];
    
    self = [super initWithRootViewController:tableView];
    
    if(self)
    {
        //self.newJob = nil; //commentato 19 novembre
    }
    
    return self;
}

//istanzia tableView per modificare offerta di lavoro già presente
- (id) initWithJob:(Job*)aJob
{    
    tableView = [[ModJobViewController alloc] initWithJob:aJob];
    ((ModJobViewController*)tableView).delegate = self;
    self = [super initWithRootViewController:tableView];
    
    if(self)
    {
        self.theNewJob = aJob;
        //self.newJob = nil; //commentato 19 novembre
    }
    
    return self;
}

#pragma mark - metodi bottoni della view
-(BOOL)validate:(Job*) job
{
    BOOL rtn = YES; 
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    
    rtn = [job isValid];
    
    if (!rtn){
        NSString *message = [NSString stringWithFormat:@"%@ formalmente \n non valida",[job invalidReason]];
        [alert setMessage:NSLocalizedString(message, @"")];
        [alert show];		
    }
    [alert release];
    return rtn;
}

-(IBAction)insertBtnPressed:(id)sender
{   
    //fa si che il testo inserito nei texfield sia preso anche se non è stata dismessa la keyboard
    [self.view endEditing:TRUE];

    if([tableView isKindOfClass:[EditJobViewController class]]){
        //setto data creazione annuncio, il formato è tale per esser compatibile con mysql
        theNewJob.date = [NSDate date];
        theNewJob.user = [[UIDevice currentDevice] uniqueIdentifier];
    }
    //NSLog(@"NSDATE IS : %@", [theNewJob stringFromDate]);
       
    //se i campi inseriti sono formalmente validi controllo connessione per invio
    if([self validate:theNewJob]){    
        //controllo stato connessione
        if(![Utilities networkReachable]){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Per favore controlla le impostazioni di rete e riprova" message:@"Impossibile collegarsi ad internet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
            
        else if([theNewJob.description isEqualToString:@""] || ([theNewJob.email isEqualToString:@""] && [theNewJob.phone isEqualToString:@""] && [theNewJob.phone2 isEqualToString:@""] && [[theNewJob urlAsString] isEqualToString:@""] )){
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Informazioni mancanti" message:@"Inserisci una breve descrizione e almeno un contatto per poter pubblicare l'annuncio" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            [alert release];
        }
        else{
             if(pwDelegate && [pwDelegate respondsToSelector:@selector(didInsertNewJob:)] && [tableView isKindOfClass: [EditJobViewController class]])
                 [pwDelegate didInsertNewJob:theNewJob]; //passo al delegato il nuovo job;
             else if(pwDelegate && [pwDelegate respondsToSelector:@selector(didInsertNewJob:)] && [tableView isKindOfClass: [ModJobViewController class]])
                     [pwDelegate didModifiedJob:theNewJob];
        }        
    }
    

    
    //[newJob release];
}

-(IBAction)cancelBtnPressed:(id)sender{
    
    //informa il delegato che è stato spinto annulla
    if(pwDelegate && [pwDelegate respondsToSelector:@selector(didCancelNewJob:)])
        [self.pwDelegate didCancelNewJob:self];    
}

-(void)activeInsertBtn:(id)sender
{
    //abilita il tasto "inserisci" se è stato scelto il settore
    tableView.navigationItem.rightBarButtonItem.enabled = YES;
}

#pragma mark - ModJobViewControllerDelegate
-(void)didDeletedJob:(id)sender{
    
    NSLog(@"CANCELLATO PREMUTO");
    if(pwDelegate && [pwDelegate respondsToSelector:@selector(didDelJob:)])
        [pwDelegate didDelJob:theNewJob];
}


#pragma mark - View lifecycle

-(void)viewWillAppear:(BOOL)animated
{    
    [super viewWillAppear:animated];
    //passo il newJob alla tabella per esser riempito
    if([tableView isKindOfClass: [EditJobViewController class]]){
        ((EditJobViewController *) tableView).job = theNewJob;
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
            
    //setto la navigationBar
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.translucent = YES;
    //tableView.navigationItem.title = @"Nuovo lavoro";
    
    //aggiungo bottone "inserisci" ed "annulla" alla barra
    UIBarButtonItem *insertButton = [[UIBarButtonItem alloc] initWithTitle:@"Invia" style:UIBarButtonItemStyleDone target:self action:@selector(insertBtnPressed:)];          
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Annulla" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtnPressed:)];     
    tableView.navigationItem.rightBarButtonItem = insertButton;
    tableView.navigationItem.leftBarButtonItem = cancelButton;
    
    //di default insertButton è disabilitato se è un nuovo lavoro
    if([tableView isKindOfClass:[EditJobViewController class]])
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
    [theNewJob release], theNewJob = nil;
    [tableView release];
    [super dealloc];
}

@end
