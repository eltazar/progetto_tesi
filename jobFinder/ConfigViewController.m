//
//  ConfigViewController.m
//  jobFinder
//
//  Created by mario greco on 29/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ConfigViewController.h"

@implementation ConfigViewController

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
        return [[sectionData objectAtIndex: section] count];    } 

    return 0;
}


//rendere più pulito e dinamico??
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sec = [sectionData objectAtIndex:indexPath.section];
    NSDictionary *rowDesc = [sec objectAtIndex:indexPath.row]; 
    NSString *dataKey = [rowDesc objectForKey:@"DataKey"];
    NSString *kind = [rowDesc objectForKey:@"kind"];
  
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: kind];
    
    //se non è recuperata creo una nuova cella
	if (cell == nil) {
        cell = [[[NSClassFromString(kind) alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kind] autorelease];
    }
    
//    if([cell isMemberOfClass:[TextFieldCell class]]){
//        cell.textField.delegate = self;
//        cell.dataKey = dataKey;
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.textLabel.text = [rowDesc objectForKey:@"label"];	 //setto la label per la cella
//    }
    
    cell.textLabel.text = [rowDesc objectForKey:@"label"];

    if ([[rowDesc objectForKey:@"kind"] isEqualToString:@"TextFieldCell"]) {
        //setto la label, stile, delegato e datakey
        ((TextFieldCell *) cell).textField.delegate = self;
        ((TextFieldCell *) cell).dataKey = dataKey;

        //setto tipo di tastiera in base al texfield
        NSString * kt = [rowDesc objectForKey:@"keyboardType"];
        NSInteger kti = [kt integerValue];
        ((TextFieldCell *)cell).textField.keyboardType = kti;
    }
    else if([[rowDesc objectForKey:@"kind"] isEqualToString:@"ActionCell"]){
        //TODO: aggiungere immagine alla cella
    }
    
    return cell;
}

//azioni per le celle selezionate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int section = indexPath.section;
    int row = indexPath.row;
    NSURL *url; 
 
    if(section == 1){
        switch (row) {
            case 0:
                NSLog(@"emaildidSelectRow");
                MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
                mail.mailComposeDelegate = self;
                
                if([MFMailComposeViewController canSendMail]){
                    [mail setToRecipients:[NSArray arrayWithObjects:EMAIL_CONTACT, nil]];
                    [mail setSubject:@"Oggetto della mail"];
                    [mail setMessageBody:@"Corpo del messaggio della nostra e-mail" isHTML:NO];
                    [self presentModalViewController:mail animated:YES];
                    [mail release];
                }
                break; 
            case 1:
                NSLog(@"url didSelectRow");
                url = [NSURL URLWithString:URL_INFO];
                //this will open the selected URL into the safari
                [[UIApplication sharedApplication]openURL: url ]; 
                break; 

        }
    }
    
    //deseleziona cella
    [tableView deselectRowAtIndexPath:indexPath animated:YES];  
    
}

//setta gli header delle sezioni
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    switch (section) {
		case 0:
			 return @"Zona preferita";
			break;
		case 1:
			return @"About Us";
			break;
		default:
			return nil;
			break;
	}
   
}

//setta i footer della sezione
//non so se è una soluzione zozza per aggiungere il footer :|, da verificare
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Inserisci un posto preferito; JobFinder ti invierà delle notifiche se è stato aggiunto un nuovo lavoro nella tua zona.";
            break;
        case 1:
            return nil;
            break;
        
        default:
            return nil;
            break;
    }
}

#pragma mark - texfield delegate


/*sembra funzionare qui, ma è meglio metterlo in TextFieldCell?
 * inoltre devo salvare le informazioni digitate dall'utente nelle impostazioni
 * dell'app, e forse dovrei trasformare l'indirizzo in coordinate.
 * vedere se implementare diretttamente una searchbar che interroga api di google
 */

// gestisce la fine dell'editing in un textField
- (void)textFieldDidEndEditing:(UITextField *)txtField
{
    //recupera la cella relativa al texfield
    TextFieldCell *cell = (TextFieldCell *) [[txtField superview] superview];
    NSLog(@"2) dataKey %@, texField %@", cell.dataKey, cell.textField.text);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{ 
	[textField resignFirstResponder];
	return YES;
}

#pragma mark - azioni dei bottoni

-(void) doneButtonClicked: (id) sender
{
    /*Application_Home/Library/Preferences	Questa directory contiene i file delle preferenze della specifica applicazione. Ci si accede con NSUserDefaults
     */
//    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
//    for (int i = 0; i < numRow; i++){        
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow: i inSection: section];
//        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//        NSString *text = ((TextFieldCell *)cell).textField.text;
//        [prefs setObject:text forKey:[NSString stringWithFormat:@"%d",i]];
//        [indexPath release];
//        [cell release];
//    }
//    NSLog(@"TESTO RIGA 0 SEZIONE 0 %@",[((TextFieldCell *)cell) data]);

    // This is suggested to synch prefs, but is not needed (I didn't put it in my tut)
//    [prefs synchronize];

    //rimuovi vista
    [UIView 
     transitionWithView:self.navigationController.view
     duration:1.0
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

////perchè richiamato 2 volte??????? 
//-(void)cellControlDidEndEditing:(NSNotification *)notification
//{
//	NSIndexPath *cellIndex = (NSIndexPath *)[notification object];
////    NSLog(@"index path.row = %d",cellIndex.row);
//	TextFieldCell *cell = (TextFieldCell *)[self.tableView cellForRowAtIndexPath:cellIndex];
////    NSLog(@"cell in controlDidEnd: %p",cell);
//	if(cell != nil)
//	{ 
//		NSLog(@"L'utente ha digitato %@ per la DataKey %@",  [cell getControlValue], cell.dataKey);
//	}		
//}


#pragma mark - View life cycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    //creo i dizionari per le sezioni
    [secA insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"street",           @"DataKey",
                         @"TextFieldCell",    @"kind", 
                         @"Via",              @"label",
                         @"",                 @"img",
                         [NSString stringWithFormat:@"%d",UIKeyboardTypeDefault], @"keyboardType",
                         nil] autorelease] atIndex: 0];
    
    [secA insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"city",             @"DataKey",
                         @"TextFieldCell",    @"kind",
                         @"Città",            @"label",
                         @"",                 @"img",
                         [NSString stringWithFormat:@"%d", UIKeyboardTypeDefault], @"keyboardType",
                         nil] autorelease] atIndex: 1];
    
    [secA insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"province",         @"DataKey",
                         @"TextFieldCell",    @"kind",
                         @"Provincia",        @"label",
                         @"",                 @"img",
                         [NSString stringWithFormat:@"%d", UIKeyboardTypeDefault], @"keyboardType",
                         nil] autorelease] atIndex: 2];
    
    [secB insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"email",            @"DataKey",
                         @"ActionCell",       @"kind",
                         @"Contattaci",       @"label",
                         @"",                 @"img",
                         nil] autorelease] atIndex: 0];
    
    [secB insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"site",             @"DataKey",
                         @"ActionCell",       @"kind",
                         @"Visita il sito",   @"label",
                         @"",                 @"img",
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - memory management

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [super dealloc];
}

@end
