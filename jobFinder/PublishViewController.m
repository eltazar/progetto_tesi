//
//  PublishViewController.m
//  jobFinder
//
//  Created by mario greco on 30/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PublishViewController.h"
#import "EditJobViewController.h"

@implementation PublishViewController
@synthesize pwDelegate, userCoordinate;



- (id) initWithStandardRootViewController
{    
    tableView = [[[EditJobViewController alloc] initWithNibName:@"RootJobViewController" bundle:nil] autorelease]; //autorelease?

    self = [super initWithRootViewController:tableView];
    
    if(self)
    {
       // NSLog(@"ok");
    }
    
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - metodi bottoni della view

-(IBAction)insertBtnPressed:(id)sender{

    //fa si che il testo inserito nei texfield sia preso anche se non è stata dismessa la keyboard
    [self.view endEditing:TRUE];
    
    //VEDERE IL PROB DELLA MEMORIA DI QUESTI TIPI DI OGGETTI
    //ricavo il job dalla tabella
    newJob = ((EditJobViewController *) tableView).job;  
    NSLog(@"************* PublishViewController************");    
    NSLog(@"user coordinate %f %f",userCoordinate.latitude,userCoordinate.longitude);    
    newJob.coordinate = CLLocationCoordinate2DMake(userCoordinate.latitude,userCoordinate.longitude);
    
    NSLog(@"newJob = %p |||| newJob.coordinate LONG %F | LAT %F",newJob, newJob.coordinate.longitude,newJob.coordinate.latitude);
    NSLog(@"job.employee = %@",newJob.employee);
    NSLog(@"***********************************************");
    
    //passo al delegato il nuovo job;
    [pwDelegate receiveAnewJob:newJob];
}

-(IBAction)cancelBtnPressed:(id)sender{
    
    //dico al delegato che è stato spinto annulla
    [self.pwDelegate publishViewControllerDidCancel:self];
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //setto la naviationBar
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.translucent = YES;
    tableView.navigationItem.title = @"Inserisci";

    //    //aggiungo bottone "inserisci" ed "annulla" alla barra
    UIBarButtonItem *insertButton = [[UIBarButtonItem alloc] initWithTitle:@"Inserisci" style:UIBarButtonItemStylePlain target:self action:@selector(insertBtnPressed:)];          
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Annulla" style:UIBarButtonItemStylePlain target:self action:@selector(cancelBtnPressed:)];     
    tableView.navigationItem.rightBarButtonItem = insertButton;
    tableView.navigationItem.leftBarButtonItem = cancelButton;

    [insertButton release];
    [cancelButton release];
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

- (void) dealloc
{
    //per ora li metto ma non so se è giusto
//    [newJob release];
    //[tableView release];
//    [pwDelegate release];
    [super dealloc];
}

//TODO: tasto inserisci grigio finchè non si è scelta la categoria!


@end
