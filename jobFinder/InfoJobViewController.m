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
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
        
    [self fillCell:cell InRow:indexPath.row inSection:indexPath.section];
    
    if([[rowDesc objectForKey:@"kind"] isEqualToString:@"TextAreaCell"]){
        //rendo la cella non editabile
        ((TextAreaCell *)cell).textView.editable = NO;
    }
    
    if([cell.detailTextLabel.text isEqualToString:@"Non disponibile"]){
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
            else if(row == 1)
                if(![job.time isEqualToString:@""])
                    cell.detailTextLabel.text = job.time;
                else cell.detailTextLabel.text = @"Non disponibile";
            else if(row == 2)
                cell.detailTextLabel.text = [job stringFromDate];
            else if(row == 3)
                cell.detailTextLabel.text = job.address;
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
                if(![cell.detailTextLabel.text isEqualToString:@"Non disponibile"]){
                    NSLog(@"riga 0 sezione 2");
                    //fa partire una chiamata
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
    else if(section == 3){
#warning permettere solo 1 volta la condivisione di un job su fb?
        if(row==0){
            NSLog(@"selezionata riga di fb");
            if (!isConnected) {
                NSLog(@"non è connesso ---> lancio login");
                [facebook authorize:permissions];
//                [self postOnFacebookWall];
            }
            else{
                NSLog(@"era gia connesso ---> invio post");
                [self postOnFacebookWall];
            }
        }
        else if(row == 1){
            
            MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
            mail.mailComposeDelegate = self;
            
            if([MFMailComposeViewController canSendMail]){
                //[mail setToRecipients:[NSArray arrayWithObjects:cell.detailTextLabel.text, nil]];
                [mail setSubject:@"Segnalazione offerta di lavoro da jobFinder"];
                [mail setMessageBody:[self createJobString] isHTML:NO];
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

//DA CANCELLARE ???? 30 ottobre
-(void) setJob:(Job*) newJob{
    if(job != newJob){
        [newJob retain];
        [job release];
        job = newJob;
    }
}


#pragma mark - Metodi utili per facebook

-(NSString*) createJobString
{
    NSMutableString *jobString = [NSMutableString stringWithFormat:@"%@",@"Ciao, vi segnalo questa opportunità di lavoro:\n\n"];
    
    [jobString appendString:[NSString stringWithFormat:@"Settore: %@ \n", [Utilities sectorFromCode:job.code]]];
    [jobString appendString:[NSString stringWithFormat:@"Vicino a: %@ \n",[job address]]];
    
    if(![job.time isEqualToString:@""])
        [jobString appendString:[NSString stringWithFormat:@"Contratto: %@ \n",job.time]];
    
    if(![job.description isEqualToString:@""])
        [jobString appendString:[NSString stringWithFormat:@"Descrizione: %@ \n",job.description]];
    if(![job.phone isEqualToString:@""])
        [jobString appendString:[NSString stringWithFormat:@"Telefono: %@ \n",job.phone]];
     
    if(![job.email isEqualToString:@""])
        [jobString appendString:[NSString stringWithFormat:@"E-mail: %@ \n",job.email]];
    
    if(![[job urlAsString] isEqualToString:@""])
        [jobString appendString:[NSString stringWithFormat:@"Url: %@ \n",[job urlAsString]]];

    return jobString;
    
}

-(void)showActivityView{
    // Show an alert with a message without the buttons.
    [msgAlert show];
    
}


-(void)stopShowingActivity{
    //[actView stopAnimating];
    [msgAlert dismissWithClickedButtonIndex:0 animated:YES];
}

-(void)postOnFacebookWall
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self showActivityView];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"175161829247160", @"app_id",
                                   [NSString stringWithFormat:@"http://maps.google.it/maps?q=%f,%f",job.coordinate.latitude,job.coordinate.longitude], @"link",
                                   @"", @"picture",
                                   @"JobFinder", @"name",
                                   @"Segnalazione di un lavoro da jobFinder", @"caption",
                                   @"JobFinder è un app per iPhone che ti permette di trovare, offrire o segnalarne un lavoro ovunque ti trovi.", @"description",
                                   [self createJobString],@"message",
                                   nil];                
    [facebook requestWithGraphPath:@"me/feed" andParams:params andHttpMethod:@"POST" andDelegate:self]; 
}

-(void)checkForPreviouslySavedAccessTokenInfo{
    // Initially set the isConnected value to NO.
    isConnected = NO;
    
    // Check if there is a previous access token key in the user defaults file.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] &&
        [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
        NSLog(@"expirationDate = %@",facebook.expirationDate);       
        // Check if the facebook session is valid.
        // If it’s not valid clear any authorization and mark the status as not connected.
        if (![facebook isSessionValid]) {
            //[facebook authorize:nil];
            NSLog(@"SESSIONE NN VALIDA");
            [facebook logout:self];
            isConnected = NO;
        }
        else {
            NSLog(@"SESSIONE VALIDA");
            isConnected = YES;
        }
    }
}

-(void)saveAccessTokenKeyInfo{
    // Save the access token key info into the user defaults.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

#pragma mark - Facebook's delegates

-(void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    // Keep this just for testing purposes.
    NSLog(@"received response");
    
}
-(void)request:(FBRequest *)request didLoad:(id)result{
    NSLog(@"facebook did load request: %@",result);
    [self stopShowingActivity];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([result isKindOfClass:[NSArray class]]) {
        // The first object in the result is the data dictionary.
        result = [result objectAtIndex:0];
    }
    if ([result objectForKey:@"first_name"]) {

    }
    else if ([result objectForKey:@"id"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Messaggio inviato" message:@"Hai condiviso questa offerta di lavoro su facebook" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

-(void)request:(FBRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"%@", [error localizedDescription]);
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if ([actView isAnimating]) {
        [self stopShowingActivity];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Errore" message:@"Non è stato possibile condividere questo contenuto su facebook, riprova" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
    [alert release];
}

-(void)fbDidLogin{
    NSLog(@"DID LOGIN");
    // Save the access token key info.
    [self saveAccessTokenKeyInfo];
    isConnected = YES;
    // Get the user's info.
    [facebook requestWithGraphPath:@"me" andDelegate:self];
    [self postOnFacebookWall];
    
}

-(void)fbDidNotLogin:(BOOL)cancelled{
    
    isConnected = NO;
}

-(void)fbDidLogout{
    // Keep this for testing purposes.
    NSLog(@"Logged out");
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
                         @"InfoCell",         @"kind", 
                         @"Settore",          @"label",
                         @"",                 @"detailLabel",
                         @"",                 @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleValue1],
                            @"style",
                         nil] autorelease] atIndex: 0];
    [secA insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"InfoCell",         @"kind", 
                         @"Contratto",        @"label",
                         @"",                 @"detailLabel",
                         @"",                 @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleValue1],
                         @"style",
                         nil] autorelease] atIndex: 1];

    [secA insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"InfoCell",         @"kind", 
                         @"Inserito il",      @"label",
                         @"",                 @"detailLabel",
                         @"",                 @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleValue1],
                            @"style",
                         nil] autorelease] atIndex: 2];
    
    [secA insertObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:
                         @"InfoCell",         @"kind", 
                         @"Zona",        @"label",
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
                         @"TextAreaCell",     @"kind",
                         @"",                 @"label",
                         @"",                 @"img",
                         nil] autorelease] atIndex: 0];
    
    [secC insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"ActionCell",       @"kind", 
                         @"Chiama",           @"label", 
                         @"call.png",         @"img", 
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleSubtitle], @"style",
                         nil]autorelease] atIndex: 0];
    
    [secC insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"ActionCell",       @"kind",
                         @"Scrivi",           @"label",
                         @"mail.png",         @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleSubtitle], @"style",
                         nil] autorelease] atIndex: 1];
    
    [secC insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"ActionCell",       @"kind", 
                         @"Visita",           @"label",
                         @"home.png",         @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleSubtitle], @"style",
                         nil]autorelease] atIndex: 2];
    
    [secD insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"ActionCell",       @"kind", 
                         @"Facebook",           @"label",
                         @"facebook.png",         @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleSubtitle], @"style",
                         nil]autorelease] atIndex: 0];
    
    [secD insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"ActionCell",       @"kind", 
                         @"E-mail",           @"label",
                         @"mail.png",         @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleSubtitle], @"style",
                         nil]autorelease] atIndex: 1];


    
    sectionData = [[NSArray alloc] initWithObjects: secA, secB, secC, secD,nil];
    sectionDescripition = [[NSArray alloc] initWithObjects:@"Informazioni generali", @"Descrizione", @"Contatti",@"Condividi con", nil];  
    
    
#warning REVERSE GECODING SPOSTARE??
    /* Quando viene caricata la view controllo se il job scaricato dal server ha il campo address a nil o @"". Se si fa partire il reverse geocoding, altrimenti vuol dire che il job era già stato visualizzato in precedenza ed era già stato fatto il geocoding. In questo 
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
    [secD autorelease];
    
    
    //###### FACEBOOK ########
    
    msgAlert = [[UIAlertView alloc] initWithTitle:@"Invio..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    actView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    actView.frame= CGRectMake(121,50, 37, 37);
    //actView.center = CGPointMake(msgAlert.frame.size.width/2,msgAlert.frame.size.height/3);
    [actView startAnimating];
    [msgAlert addSubview:actView];
    
    // Set the permissions.
    // Without specifying permissions the access to Facebook is imposibble.
    permissions = [[NSArray arrayWithObjects:@"publish_stream", nil] retain];
    
    // Set the Facebook object we declared. We’ll use the declared object from the application
    // delegate.
    facebook = [[Facebook alloc] initWithAppId:@"175161829247160" andDelegate:self];
    
    // Check if there is a stored access token.
    [self checkForPreviouslySavedAccessTokenInfo];
    NSLog(@"is connected = %d",isConnected);

    // Specify the lblUser label's message depending on the isConnected value.
    // If the access token not found and the user is not connected then prompt him/her to login.
//    if (isConnected){
//        // Get the user's name from the Facebook account. The message will be set later.
//        [facebook requestWithGraphPath:@"me" andDelegate:self];
//    }
}


- (void)viewDidUnload
{
    [permissions release];
    permissions = nil;
    [facebook release];
    facebook = nil;
    [actView release];
    actView = nil;
    [msgAlert release];
    msgAlert = nil;
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
    NSLog(@"DALLOC");
    [permissions release];
    [facebook release];
    [msgAlert release];
    [actView release];
    [job release];
    [super dealloc];
}

@end
