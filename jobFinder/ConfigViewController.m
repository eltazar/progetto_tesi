//
//  ConfigViewController.m
//  jobFinder
//
//  Created by mario greco on 29/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ConfigViewController.h"
#import "BaseCell.h"
#import "SearchZoneViewController.h"


#define EMAIL_CONTACT @"el-tazar@hotmail.it"
#define URL_INFO @"http://www.google.it"

@implementation ConfigViewController
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization 
    }
    return self;
}

#pragma mark - UITableViewDataSource delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return sectionDescripition.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section
{   
    if(sectionData){
        return [[sectionData objectAtIndex: section] count];
    } 

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sec = [sectionData objectAtIndex:indexPath.section];
    NSDictionary *rowDesc = [sec objectAtIndex:indexPath.row]; 
    NSString *dataKey = [rowDesc objectForKey:@"DataKey"];
    NSString *kind = [rowDesc objectForKey:@"kind"];
    int cellStyle = UITableViewCellStyleDefault;
    
    BaseCell *cell = (BaseCell *)[tableView dequeueReusableCellWithIdentifier: dataKey];
    
    //se non è recuperata creo una nuova cella
	if (cell == nil) {
        cell = [[[NSClassFromString(kind) alloc] initWithStyle: cellStyle reuseIdentifier:kind withDictionary:rowDesc] autorelease];
    }
    
//    if(indexPath.section == 0 && indexPath.row == 0){
//        //per gestire linee di testo multiple nella cella
//        cell.textLabel.text = @"";
//        cell.detailTextLabel.text = [[[sectionData objectAtIndex:0] objectAtIndex:0] objectForKey:@"label"];
//        cell.detailTextLabel.numberOfLines = 2;
//        cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
//    }

    return cell;
}

//setta gli header delle sezioni
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{  
     return [sectionDescripition objectAtIndex:section];
}

//setta i footer della sezione
//non so se è una soluzione zozza per aggiungere il footer :|, da verificare
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Cerca e seleziona un indirizzo preferito; JobFinder ti invierà delle notifiche se è stato aggiunto un nuovo lavoro nella tua zona.";
            break;
        case 1:
            return nil;
            break;
        
        default:
            return nil;
            break;
    }
}

#pragma mark - TableViewDelegate

//azioni per le celle selezionate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    int section = indexPath.section;
    int row = indexPath.row;
    NSURL *url; 
    
    if(section == 0){
        switch (row) {
            case 1:
                searchZone = [[[SearchZoneViewController alloc] initWithNibName: @"SearchZoneViewController" bundle: nil] autorelease];
                [searchZone setDelegate:self];
                [self.navigationController pushViewController:searchZone animated:YES];
                break;
                
            default:
                break;
        }
    }
    else if(section == 1){
        switch (row) {
            case 0:
                NSLog(@"emaildidSelectRow");
                MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
                mail.mailComposeDelegate = self;
                
                if([MFMailComposeViewController canSendMail]){
                    [mail setToRecipients:[NSArray arrayWithObjects:EMAIL_CONTACT, nil]];
                    [mail setSubject:@"Oggetto della mail"];
                    [mail setMessageBody:@"" isHTML:NO];
                    [self presentModalViewController:mail animated:YES];
                    [mail release];
                }
                break; 
            case 1:
                NSLog(@"url didSelectRow");
                url = [NSURL URLWithString:URL_INFO];
                [[UIApplication sharedApplication]openURL: url ]; 
                break; 
                
        }
    }
    
    //deseleziona la cella
    [tableView deselectRowAtIndexPath:indexPath animated:YES];  
    
}

#pragma mark - azioni dei bottoni

-(void) doneButtonClicked: (id) sender
{
    //rimuove vista
    [UIView 
     transitionWithView:self.navigationController.view
     duration:0.8
     options:UIViewAnimationOptionTransitionFlipFromLeft
     animations:^{ 
         [self.navigationController 
          popViewControllerAnimated:NO];
     }
     completion:NULL];
}

//torna alla vista precedente una volta inviata o annullata un'email
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    //[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
    [self dismissModalViewControllerAnimated:YES];
    
	if (result == MFMailComposeResultFailed){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Messaggio non inviato!" message:@"Non è stato possibile inviare la tua e-mail" delegate:self cancelButtonTitle:@"Annulla" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
    
   // [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - SearchZoneDelegate

-(void) didSelectedPreferredAddress:(NSString *)address withLatitude:(CLLocationDegrees)latitude andLongitude:(CLLocationDegrees) longitude
{
    //una volta selezionata la zona preferita viene salvata nelle impostazioni personali dell'utente
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
   [prefs setObject:address forKey:@"address"];
   [prefs setObject: [NSNumber numberWithDouble:latitude] forKey: @"lat"];
   [prefs setObject: [NSNumber numberWithDouble:longitude] forKey: @"long"];
    
    //    NSLog(@"dato nel prefs: %@",[prefs objectForKey:cell.dataKey]);
    //    [prefs synchronize];
    
    //aggiorno il model per mostrare i cambiamenti fatti alla tabella
    [[[sectionData objectAtIndex:0] objectAtIndex:0] setObject:address forKey:@"label"];
    [self.tableView reloadData];    
    //avviso il delegato cnhe ho scelto la zona preferita e gli passo le coordinate
    [delegate didSelectedFavouriteZone:CLLocationCoordinate2DMake(latitude,longitude)]; 
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - View life cycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if([prefs objectForKey:@"address"] == nil || [[prefs objectForKey:@"address"] isEqualToString:@""]){
        [prefs setObject:@"" forKey:@"address"];
    }

    //setta titolo vista
    [self setTitle:@"Impostazioni"];
    self.navigationItem.hidesBackButton = TRUE;
    //aggiungo bottone "fatto" alla barra e setto azione
    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Fatto" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonClicked:)];          
    self.navigationItem.rightBarButtonItem = anotherButton;
    [anotherButton release];
    
    //creo le sezioni
    NSMutableArray *secA = [[NSMutableArray alloc] init];
    NSMutableArray *secB = [[NSMutableArray alloc] init];
    
    
    [secA insertObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:
                         @"bookmarks",              @"DataKey",
                         @"InfoCell",               @"kind",
                         [prefs objectForKey:@"address"], @"label",
                         @"",                       @"detailLabel",
                         @"star.png",               @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleDefault], @"style",
                         nil] autorelease] atIndex: 0];

    [secA insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"search",           @"DataKey",
                         @"ActionCell",       @"kind",
                         @"Cerca zona",       @"label",
                         @"search.png",                 @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleDefault], @"style",
                         nil] autorelease] atIndex: 1];
    
    [secB insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"email",            @"DataKey",
                         @"ActionCell",       @"kind",
                         @"Contattaci",       @"label",
                         @"mail.png",         @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleValue1], @"style",
                         nil] autorelease] atIndex: 0];
    
    [secB insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"site",             @"DataKey",
                         @"ActionCell",       @"kind",
                         @"Visita il sito",   @"label",
                         @"home.png",                 @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleValue1], @"style",
                         nil]autorelease] atIndex: 1];
    
    sectionData = [[NSArray alloc] initWithObjects: secA, secB, nil];
    sectionDescripition = [[NSArray alloc] initWithObjects:@"Zona preferita", @"About Us",nil];
    
    [secA autorelease];
    [secB autorelease];    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
//    sectionDescripition = nil;
//    sectionData = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

//Implement loadView to create a view hierarchy programmatically, without using a nib.
//- (void)loadView
//{
//    
//}

#pragma mark - memory management

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc 
{
    [sectionDescripition release];
    [sectionData release];  
//    [searchZone release];
    [super dealloc];
}

@end
