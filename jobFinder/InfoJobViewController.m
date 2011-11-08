//
//  InfoJobViewController.m
//  jobFinder
//
//  Created by mario greco on 03/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InfoJobViewController.h"
#import <MessageUI/MessageUI.h>
#import "BaseCell.h"
#import "GeoDecoder.h"
#import <objc/runtime.h>


@implementation InfoJobViewController

-(id) initWithJob:(Job *)aJob
{
    self = [super initWithNibName:@"RootJobViewController" bundle:nil];
    if (self) {
        // Custom initialization
#warning giusto fare così???
        job = [aJob retain]; //??? GIUSTO????
    }
    return self;
    
}

#pragma mark - DataSourceProtocol

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray *sec = [sectionData objectAtIndex:indexPath.section];
    NSDictionary *rowDesc = [sec objectAtIndex:indexPath.row]; 
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
        
    [self fillCell:cell InRow:indexPath.row inSection:indexPath.section];
    
    if([[rowDesc objectForKey:@"kind"] isEqualToString:@"TextAreaCell"]){
        //rendo la cella non editabile
        ((TextAreaCell *)cell).textView.editable = NO;
    }
    
    return cell;
}    

/*forse questo è il modo più semplice/efficiente per riempire ogni riga della tabella job.
 * la classe incapsulando un job ha tutti i dati per completare la tabella
 */
-(void) fillCell:(UITableViewCell*)cell InRow:(int)row inSection:(int)section
{
    //PASSARE UN JOB!!!!
    
//    NSLog(@"sectio = %d , row = %d", section, row);
    
    switch (section) {
        case 0:
            if(row == 0)
                cell.detailTextLabel.text = job.employee;
            else if(row == 1)
                cell.detailTextLabel.text = [job stringFromDate];
            else if(row == 2)
                cell.detailTextLabel.text = job.address;
            else if(row == 3)
                cell.detailTextLabel.text = job.city;
            
            break;
        case 1:
            if(row == 0){
                if(![job.description isEqualToString:@""])
                    ((TextAreaCell*)cell).textView.text = job.description;
                else ((TextAreaCell*)cell).textView.text = @"Descrizione non disponibile";
            }
                break;
        case 2:
            if(row == 0){
                if(![job.phone isEqualToString:@""])
                    cell.detailTextLabel.text = job.phone;
                else cell.detailTextLabel.text = @"Non disponibile";
            }
            else if(row == 1){
                if(![job.email isEqualToString:@""])
                    cell.detailTextLabel.text = job.email;
                else cell.detailTextLabel.text = @"Non disponibile";
            } 
            else if(row == 2){
                if(![[job urlAsString] isEqualToString:@""])
                    cell.detailTextLabel.text = job.urlAsString;
                else cell.detailTextLabel.text = @"Non disponibile";
            }
            break;
        default:
            break;
    }   

}

//azioni per le celle selezionate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int section = indexPath.section;
    int row = indexPath.row;
    NSURL *url; 
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if(section == 2){
        switch (row) {
            case 0:
                NSLog(@"riga 0 sezione 2");
                UIDevice *device = [UIDevice currentDevice];    
                if ([[device model] isEqualToString:@"iPhone"]){
                
                    if(![cell.detailTextLabel.text isEqualToString:@"Non disponibile"]){
                        NSString *number = [NSString stringWithFormat:@"%@%@", @"tel://", cell.detailTextLabel.text];
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:number]];
                    }
                }
                else{
                    UIAlertView *Notpermitted=[[UIAlertView alloc] initWithTitle:@"Attenzione" message:@"Il tuo device non supporta questa feature." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [Notpermitted show];
                        [Notpermitted release];
                }
                break;
                
            case 1:
                NSLog(@"emaildidSelectRow");
                if(![cell.detailTextLabel.text isEqualToString:@"Non disponibile"]){
                    MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
                    mail.mailComposeDelegate = self;
                    
                    if([MFMailComposeViewController canSendMail]){
                        [mail setToRecipients:[NSArray arrayWithObjects:cell.detailTextLabel.text, nil]];
                        [mail setSubject:@"Oggetto della mail"];
                        [mail setMessageBody:@"Corpo del messaggio della nostra e-mail" isHTML:NO];
                        [self presentModalViewController:mail animated:YES];
                        [mail release];
                    }
                }
                break;  
            case 2:
                NSLog(@"url didSelectRow");
                if(![cell.detailTextLabel.text isEqualToString:@"Non disponibile"]){
                    url = [NSURL URLWithString:cell.detailTextLabel.text];
                    //this will open the selected URL into the safari
                    [[UIApplication sharedApplication]openURL: url ]; 
                }
                break; 
        }
    }
    
    //deseleziona cella
    [tableView deselectRowAtIndexPath:indexPath animated:YES];  
    
}


#pragma mark - MFMailComposeViewControllerDelegate

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

//DA CANCELLARE ???? 30 ottobre
-(void) setJob:(Job*) newJob{
    if(job != newJob){
        [newJob retain];
        [job release];
        job = newJob;
    }
}

#pragma mark - GeodecoderDelegate
-(void)didReceivedGeoDecoderData:(NSDictionary *)geoData
{
    NSString *address;
    
    if([[geoData objectForKey:@"status"] isEqualToString:@"OK"]){
        
        NSArray *resultsArray = [geoData objectForKey:@"results"];

        NSDictionary *data = [resultsArray objectAtIndex:0];
        //NSLog(@"DICTIONARY ESTRATTO \n :%@",[data objectForKey:@"address_components"]); //array
        //NSLog(@"CLASSE: %s", class_getName([[data objectForKey:@"address_components"] class]));
        
        NSArray *dataArray = [data objectForKey:@"address_components"];
        
    //    NSLog(@"CLASSE: %s", class_getName([[dataArray objectAtIndex:0] class]));
        //NSLog(@"DATA ARRAY: %@", [[dataArray objectAtIndex:0] objectForKey:@"long_name"]);// 0 = dizionario street number
        
    #warning fatto a mano ma deve farlo se c'è errore nel reverse gecoding, CORREGGERE!!!!
        address = @""; //dove mettere "non disponibile" ?
    #warning  CONTROLLARE dataArray quanti elementi ha l'array.
        NSString *street = [[dataArray objectAtIndex:1] objectForKey:@"long_name"];
        NSString *number = [[dataArray objectAtIndex:0] objectForKey:@"long_name"];    
        //formatto la stringa address 
        if(street != nil && !([street isEqualToString:@""])){
            address = [NSString stringWithFormat:@"%@", street];
            if( number != nil && !([number isEqualToString:@""]))
                address = [NSString stringWithFormat:@"%@, %@", address, number];
            
        }
    }
    else{
        address = @"Non disponibile";
    }
    job.address = address;
    //aggiorno il model usando la stringa address e ricarico i dati della tabella 
    [[[sectionData objectAtIndex:0] objectAtIndex:2] setObject:address forKey:@"detailLabel"];
    [self.tableView reloadData];        
}


    

#pragma mark - View lifecycle

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"Lavoro"]; 
    
    //inizializzo tabella
    NSMutableArray *secA = [[NSMutableArray alloc] init];
    NSMutableArray *secB = [[NSMutableArray alloc] init];
    NSMutableArray *secC = [[NSMutableArray alloc] init];
    
    [secA insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"InfoCell",         @"kind", 
                         @"Impiego",          @"label",
                         @"",                 @"detailLabel",
                         @"",                 @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleValue1],
                            @"style",
                         nil] autorelease] atIndex: 0];
    [secA insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"InfoCell",         @"kind", 
                         @"Inserito il",      @"label",
                         @"",                 @"detailLabel",
                         @"",                 @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleValue1],
                            @"style",
                         nil] autorelease] atIndex: 1];
    
    [secA insertObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:
                         @"InfoCell",         @"kind", 
                         @"Indirizzo",        @"label",
                         @"",                 @"detailLabel",
                         @"",                 @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleValue1],
                         @"style",
                         nil] autorelease] atIndex: 2];
    
//    [secA insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
//                         @"InfoCell",         @"kind", 
//                         @"Città",            @"label",
//                         @"",                 @"img",
//                         nil]autorelease] atIndex: 3];
    //descrizione
    [secB insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"TextAreaCell",     @"kind",
                         @"",                 @"label",
                         @"",                 @"img",
                         nil] autorelease] atIndex: 0];
    
    [secC insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"ActionCell",       @"kind", 
                         @"Chiama",           @"label", 
                         @"",                 @"img", 
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleSubtitle], @"style",
                         nil]autorelease] atIndex: 0];
    
    [secC insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"ActionCell",       @"kind",
                         @"Scrivi",           @"label",
                         @"mail.png",                 @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleSubtitle], @"style",
                         nil] autorelease] atIndex: 1];
    
    [secC insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"ActionCell",       @"kind", 
                         @"Visita",           @"label",
                         @"home.png",                 @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleSubtitle], @"style",
                         nil]autorelease] atIndex: 2];
    
    sectionData = [[NSArray alloc] initWithObjects: secA, secB, secC, nil];
    sectionDescripition = [[NSArray alloc] initWithObjects:@"Informazioni generali", @"Descrizione", @"Contatti", nil];  
    
    
#warning REVERSE GECODING SPOSTARE??
    /* Quando viene caricata la view controllo se il job scaricato dal server ha il campo address a nil o @"". Se si fa partire il reverse geocoding, altrimenti vuol dire che il job era già stato caricato in precedenza ed era già stato fatto il geocoding. In questo 
        modo il reverse gecoding è fatto una volta sola, appena scaricato un job dal server.
     */
    if(job.address == nil || [job.address isEqualToString:@""] || [job.address isEqualToString:@"Non disponibile"]){
        NSLog(@"FACCIO REVERSE GECODING!");
        GeoDecoder *geoDec = [[GeoDecoder alloc] init];
        [geoDec setDelegate:self];
        [geoDec searchAddressForCoordinate:job.coordinate];
        [geoDec release];
    }
    
    [secA autorelease];
    [secB autorelease];
    [secC autorelease];   
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

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void) dealloc
{   
    [job release];
    [super dealloc];
}

@end
