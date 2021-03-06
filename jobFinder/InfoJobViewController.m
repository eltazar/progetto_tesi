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
#import "Utilities.h"
#import "FBConnect.h"
#import "FBDialog.h"
#import "Facebook.h"
#import "jobFinderAppDelegate.h"
#import "InfoCell.h"

@implementation InfoJobViewController

-(id) initWithJob:(Job *)aJob
{
    self = [super initWithNibName:@"RootJobViewController" bundle:nil];
    if (self) {
        // Custom initialization
        job = [aJob retain];
    }
    return self;
    
}

#pragma mark - DataSourceProtocol

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSArray *sec = [sectionData objectAtIndex:indexPath.section];
    NSDictionary *rowDesc = [sec objectAtIndex:indexPath.row]; 
    
    if(indexPath.section == 0 && indexPath.row==3 && [job.address isEqualToString:@""]){
        //NSLog(@"cellForRow: ritorno Spinner Cell");
        return spinnerCell;
    }
        //[[[sectionData objectAtIndex:0] objectAtIndex:3] setObject:@"spinner" forKey:@"DataKey"];
    //else [[[sectionData objectAtIndex:0] objectAtIndex:3] setObject:@"regular" forKey:@"DataKey"];
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
        
    [self fillCell:cell InRow:indexPath.row inSection:indexPath.section];
    
    if([[rowDesc objectForKey:@"kind"] isEqualToString:@"TextAreaCell"]){
        //rendo la cella non editabile
        ((TextAreaCell *)cell).textView.editable = NO;
    }
    
    if([cell.detailTextLabel.text isEqualToString:@"Non specificato"]){
        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    return cell;
}    

//riempe le celle con i relativi dati, semplifica anche il riuso di una cella
-(void) fillCell:(UITableViewCell*)cell InRow:(int)row inSection:(int)section
{
    //PASSARE UN JOB!!!!
    
//    NSLog(@"sectio = %d , row = %d", section, row);
    
    switch (section) {
        case 0:
            if(row == 0)
                cell.detailTextLabel.text = [Utilities sectorFromCode:job.code];
            else if(row == 1){
                if(job.time != nil && ![job.time isEqualToString:@""])
                    cell.detailTextLabel.text = job.time;
                else cell.detailTextLabel.text = @"Non specificato";
            }
            else if(row == 2)
                cell.detailTextLabel.text = [job stringFromDate];
            else if(row == 3){
                if([job.address isEqualToString:@""]){
                }
                else{
                    cell.accessoryView = nil;
                    cell.detailTextLabel.text = job.address;
                }
            }
           // else if(row == 4)
                //cell.detailTextLabel.text = job.city;
            
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
                else cell.detailTextLabel.text = @"Non specificato";
            }
            if(row == 1){
                if(![job.phone2 isEqualToString:@""])
                    cell.detailTextLabel.text = job.phone2;
                else cell.detailTextLabel.text = @"Non specificato";
            }
            else if(row == 2){
                if(![job.email isEqualToString:@""])
                    cell.detailTextLabel.text = job.email;
                else cell.detailTextLabel.text = @"Non specificato";
            } 
            else if(row == 3){
                if(![[job urlAsString] isEqualToString:@""])
                    cell.detailTextLabel.text = job.urlAsString;
                else cell.detailTextLabel.text = @"Non specificato";
            }
            break;
        default:
            break;
    }   

}

#pragma mark - Metodi utili per facebook

-(NSString*) createJobString:(NSString*)sender
{
    NSMutableString *jobString;
    
    if([sender isEqualToString:@"mail"])
        jobString = [NSMutableString stringWithFormat:@"%@",@"<html><body>"];
    else jobString = [NSMutableString stringWithFormat:@"%@",@""];
    
    [jobString appendString:[NSString stringWithFormat:@"<b>Settore:</b> %@ ", [Utilities sectorFromCode:job.code]]];
    [jobString appendString:[NSString stringWithFormat:@"<b>Vicino a:</b> %@ ",[job address]]];
    
    if(![job.time isEqualToString:@""])
        [jobString appendString:[NSString stringWithFormat:@"<b>Contratto:</b> %@ ",job.time]];
    
    if(![job.description isEqualToString:@""])
        [jobString appendString:[NSString stringWithFormat:@"<b>Descrizione:</b> %@ ",job.description]];
    if(![job.phone isEqualToString:@""])
        [jobString appendString:[NSString stringWithFormat:@"<b>Telefono:</b> %@ ",job.phone]];
    if(![job.phone2 isEqualToString:@""])
        [jobString appendString:[NSString stringWithFormat:@"<b>Telefono 2:</b> %@ ",job.phone2]];
    
    if(![job.email isEqualToString:@""])
        [jobString appendString:[NSString stringWithFormat:@"<b>E-mail:</b> %@ ",job.email]];
    
    if(![[job urlAsString] isEqualToString:@""])
        [jobString appendString:[NSString stringWithFormat:@"<b>Url:</b> %@ ",[job urlAsString]]];
    
    if([sender isEqualToString:@"mail"])
        [jobString appendFormat:@"</body></html>",nil];
    
    return jobString;
    
}

-(void)postOnFacebookWall
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"175161829247160", @"app_id",
                                   @"http://www.sapienzaapps.it/jobfinder/index.html", @"link",
                                   @"http://www.sapienzaapps.it/jobfinder/Icon@2x.png", @"picture",
                                   @"Segnalazione di un'offerta di lavoro attraverso JobNavigator", @"name",
                                   [self createJobString:@"fb"], @"caption",
                                   @"JobNavigator è un App social per iPhone che ti permette di trovare, offrire o segnalarne un lavoro ovunque ti trovi e di ricevere notifiche quando c'è un nuovo lavoro nella tua zona di interesse.",@"description",
                                   nil];                
    //[facebook requestWithGraphPath:@"me/feed" andParams:params andHttpMethod:@"POST" andDelegate:self]; 
    
    [appDelegate.facebook dialog:@"feed" andParams:params andDelegate:self];
    
}


-(void)logoutFromFB{
    //eseguo logout e rimuovo token
    [appDelegate.facebook logout:appDelegate];
    //    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    //    [defaults removeObjectForKey:@"FBAccessTokenKey"];
    //    [defaults removeObjectForKey:@"FBExpirationDateKey"];
    //    [defaults synchronize];
}

-(void)FBdidLogout{
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
}

-(void)FBdidLogin{
    
    if(waitingForFacebook){
        [self postOnFacebookWall];
        waitingForFacebook = NO;
    }
    [self.navigationItem setRightBarButtonItem:logoutBtn animated:YES];
}

-(void)FBerrLogin{
    waitingForFacebook = NO;
}


#pragma mark - TableViewDelegate

//azioni per le celle selezionate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int section = indexPath.section;
    int row = indexPath.row;
    NSURL *url; 
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if(section == 2){
        switch (row) {
            case 0:
                if(![cell.detailTextLabel.text isEqualToString:@"Non specificato"]){
                    //fa partire una chiamata
                    UIDevice *device = [UIDevice currentDevice];    
                    if ([[device model] isEqualToString:@"iPhone"]){
                        
                        if(![cell.detailTextLabel.text isEqualToString:@"Non specificato"]){
                            NSString *number = [NSString stringWithFormat:@"%@%@", @"tel://", cell.detailTextLabel.text];
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:number]];
                        }
                    }
                    else{
                        UIAlertView *Notpermitted=[[UIAlertView alloc] initWithTitle:@"Attenzione" message:@"Il tuo device non supporta questa feature." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [Notpermitted show];
                        [Notpermitted release];
                    }
                }
                break;
                
            case 1:
                if(![cell.detailTextLabel.text isEqualToString:@"Non specificato"]){
                    //fa partire una chiamata
                    UIDevice *device = [UIDevice currentDevice];    
                    if ([[device model] isEqualToString:@"iPhone"]){
                        
                        if(![cell.detailTextLabel.text isEqualToString:@"Non Specificato"]){
                            NSString *number = [NSString stringWithFormat:@"%@%@", @"tel://", cell.detailTextLabel.text];
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:number]];
                        }
                    }
                    else{
                        UIAlertView *Notpermitted=[[UIAlertView alloc] initWithTitle:@"Attenzione" message:@"Il tuo device non supporta questa feature." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [Notpermitted show];
                        [Notpermitted release];
                    }
                }
                break;
                
            case 2:
                if(![cell.detailTextLabel.text isEqualToString:@"Non specificato"]){
                    MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
                    mail.mailComposeDelegate = self;
                    
                    if([MFMailComposeViewController canSendMail]){
                        [mail setToRecipients:[NSArray arrayWithObjects:cell.detailTextLabel.text, nil]];
                        [mail setSubject:@"Risposta ad annuncio di lavoro da JobNavigator"];
                        [mail setMessageBody:@"" isHTML:NO];
                        [self presentModalViewController:mail animated:YES];
                        [mail release];
                    }
                }
                break;  
            case 3:
                if(![cell.detailTextLabel.text isEqualToString:@"Non specificato"]){
                    url = [NSURL URLWithString:cell.detailTextLabel.text];
                    //this will open the selected URL into the safari
                    [[UIApplication sharedApplication]openURL: url ]; 
                }
                break; 
        }
    }
    else if(section == 3){
        if(row==0){
            if (![appDelegate.facebook isSessionValid]) {
                [appDelegate logIntoFacebook];
                waitingForFacebook = YES;
//                [self postOnFacebookWall];
            }
            else{
                [self postOnFacebookWall];
            }
        }
        else if(row == 1){
            
            MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
            mail.mailComposeDelegate = self;
            
            if([MFMailComposeViewController canSendMail]){
                //[mail setToRecipients:[NSArray arrayWithObjects:cell.detailTextLabel.text, nil]];
                [mail setSubject:@"Segnalazione offerta di lavoro da JobNavigator"];
                [mail setMessageBody:[self createJobString:@"mail"] isHTML:YES];
                [self presentModalViewController:mail animated:YES];
                [mail release];
            }
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


#pragma mark - FacebookDialogDelegate

- (void) dialogDidNotComplete:(FBDialog *)dialog
{
//    NSLog(@"DIALOG DID NOT COMPLETE");
}

- (void)dialogCompleteWithUrl:(NSURL *)url{
    
    //NSLog(@"DIALOG COMPLETE WITH URL : %@", [url absoluteString]);
    
    if ([[url absoluteString] rangeOfString:@"?post_id="].location == NSNotFound )
    {
        NSLog(@"post non inserito");
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Messaggio pubblicato sulla tua bacheca" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
        
    }
}

- (void) dialogDidNotCompleteWithUrl:(NSURL *)url{
    NSLog(@"DIALOG NOT COMPLETE WITH URL : %@", [url absoluteString]);
}

- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error{
    
    NSLog(@"DIALOG FAIL WITH ERROR: %@", error);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errore" message:@"Non è stato possibile condividere questo contenuto su facebook, riprova" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

- (void)dialogDidComplete:(FBDialog *)dialog{
    

}







#pragma mark - GeodecoderDelegate

//date le coordinate del job cerca il relativo indirizzo e lo mostra nella tabella
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
        
        address = @""; //dove mettere "non disponibile" ?
        NSString *street;
        NSString *number;
        if(dataArray != nil && dataArray.count != 0){
            street = [[dataArray objectAtIndex:1] objectForKey:@"long_name"];
            number = [[dataArray objectAtIndex:0] objectForKey:@"long_name"]; 
        }
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
    [[[sectionData objectAtIndex:0] objectAtIndex:3] setObject:address forKey:@"detailLabel"];
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
    
    //creo il model della tabella
    NSMutableArray *secA = [[NSMutableArray alloc] init];
    NSMutableArray *secB = [[NSMutableArray alloc] init];
    NSMutableArray *secC = [[NSMutableArray alloc] init];
    NSMutableArray *secD = [[NSMutableArray alloc] init];
    
    [secA insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"regular",          @"DataKey",
                         @"InfoCell",         @"kind", 
                         @"Settore",          @"label",
                         @"",                 @"detailLabel",
                         @"",                 @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleValue1],
                            @"style",
                         nil] autorelease] atIndex: 0];
    [secA insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"regular",          @"DataKey",
                         @"InfoCell",         @"kind", 
                         @"Contratto",        @"label",
                         @"",                 @"detailLabel",
                         @"",                 @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleValue1],
                         @"style",
                         nil] autorelease] atIndex: 1];

    [secA insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"regular",          @"DataKey",
                         @"InfoCell",         @"kind", 
                         @"Inserito il",      @"label",
                         @"",                 @"detailLabel",
                         @"",                 @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleValue1],
                            @"style",
                         nil] autorelease] atIndex: 2];
    
    [secA insertObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:
                         @"regular",                 @"DataKey",
                         @"InfoCell",         @"kind", 
                         @"Zona",             @"label",
                         @"",                 @"detailLabel",
                         @"",                 @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleValue1],
                         @"style",
                         nil] autorelease] atIndex: 3];
    
//    [secA insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
//                         @"InfoCell",         @"kind", 
//                         @"Città",            @"label",
//                         @"",                 @"img",
//                         nil]autorelease] atIndex: 3];
    //descrizione
    [secB insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"regular",          @"DataKey",
                         @"TextAreaCell",     @"kind",
                         @"",                 @"label",
                         @"",                 @"img",
                         nil] autorelease] atIndex: 0];
    
    [secC insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"regular",          @"DataKey",
                         @"ActionCell",       @"kind", 
                         @"Chiama 1",           @"label", 
                         @"call.png",         @"img", 
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleSubtitle], @"style",
                         nil]autorelease] atIndex: 0];
    
    [secC insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"regular",          @"DataKey",
                         @"ActionCell",       @"kind", 
                         @"Chiama 2",           @"label", 
                         @"call.png",         @"img", 
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleSubtitle], @"style",
                         nil]autorelease] atIndex: 1];
    
    [secC insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"regular",          @"DataKey",
                         @"ActionCell",       @"kind",
                         @"Scrivi",           @"label",
                         @"mail.png",         @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleSubtitle], @"style",
                         nil] autorelease] atIndex: 2];
    
    [secC insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"regular",          @"DataKey",
                         @"ActionCell",       @"kind", 
                         @"Visita",           @"label",
                         @"home.png",         @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleSubtitle], @"style",
                         nil]autorelease] atIndex: 3];
    
    [secD insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"regular",          @"DataKey",
                         @"ActionCell",       @"kind", 
                         @"Facebook",           @"label",
                         @"facebook.png",         @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleSubtitle], @"style",
                         nil]autorelease] atIndex: 0];
    
    [secD insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"regular",          @"DataKey",
                         @"ActionCell",       @"kind", 
                         @"E-mail",           @"label",
                         @"mail.png",         @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleSubtitle], @"style",
                         nil]autorelease] atIndex: 1];


    
    sectionData = [[NSArray alloc] initWithObjects: secA, secB, secC, secD,nil];
    sectionDescripition = [[NSArray alloc] initWithObjects:@"Informazioni generali", @"Descrizione", @"Contatti",@"Condividi con", nil];  
    
    
    /* Quando viene caricata la view controllo se il job scaricato dal server ha il campo address a nil o @"". Se si fa partire il reverse geocoding, altrimenti vuol dire che il job era già stato visualizzato in precedenza ed era già stato fatto il geocoding. In questo 
        modo il reverse gecoding è fatto una volta sola, appena scaricato un job dal server.
     */
    if(job.address == nil || [job.address isEqualToString:@""] || [job.address isEqualToString:@"Non disponibile"]){
        //NSLog(@"FACCIO REVERSE GECODING!");
        geoDec = [[GeoDecoder alloc] init];
        [geoDec setDelegate:self];
        [geoDec searchAddressForCoordinate:job.coordinate];
    }
    
    [secA autorelease];
    [secB autorelease];
    [secC autorelease];   
    [secD autorelease];
    
    //setto il pulsante per il logout
    UIImage *buttonImage = [UIImage imageNamed:@"logout.png"];

    UIButton *tmpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tmpButton setImage:buttonImage forState:UIControlStateNormal];
    tmpButton.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [tmpButton addTarget:self action:@selector(logoutFromFB) forControlEvents:UIControlEventTouchUpInside];
    
    
    //###### FACEBOOK ########
    
    logoutBtn = [[UIBarButtonItem alloc] initWithCustomView:tmpButton];
    
    appDelegate = (jobFinderAppDelegate*) [[UIApplication sharedApplication] delegate];

    //controllo se ci sono token e sessione precedenti valide
    [appDelegate checkForPreviouslySavedAccessTokenInfo];
       
    //mostra il tasto per il logout se connesso
    if([appDelegate.facebook isSessionValid]){
       // NSLog(@"DID LOAD CONNECTED");
        self.navigationItem.rightBarButtonItem = logoutBtn;
    }
    else{
        //NSLog(@"DID LOAD NOT CONNECTED");
        self.navigationItem.rightBarButtonItem = nil;
    }
    

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(FBdidLogout)
                                                 name:@"FBdidLogout"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(FBdidLogin)
                                                 name:@"FBdidLogin"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(FBerrLogin)
                                                 name:@"FBerrLogin"
                                               object:nil];
    
    waitingForFacebook = NO;
    
    // spinner cell
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] 
               initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    spinnerCell = [[InfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"spinner" withDictionary:[secA objectAtIndex:3]];
    spinnerCell.accessoryView = spinner;
    [spinner release];
}


- (void)viewDidUnload
{
    [spinnerCell release];
    spinnerCell = nil;
    [logoutBtn release];
    logoutBtn = nil;
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
   // NSLog(@"DEALLOC");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [geoDec setDelegate:nil];
    [geoDec release];
    [spinnerCell release];
    [logoutBtn release];
    [job release];
    [super dealloc];
}

@end
