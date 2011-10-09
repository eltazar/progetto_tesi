//
//  InfoJobViewController.m
//  jobFinder
//
//  Created by mario greco on 03/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InfoJobViewController.h"
#import <MessageUI/MessageUI.h>

@implementation InfoJobViewController

-(id) initWithJob:(Job *)aJob
{
    self = [super initWithNibName:@"RootJobViewController" bundle:nil];
    if (self) {
        // Custom initialization
        job = aJob; //??? GIUSTO????
    }
    return self;
    
}

#pragma mark - DataSourceProtocol

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    NSArray *sec = [sectionData objectAtIndex:indexPath.section];
    NSDictionary *rowDesc = [sec objectAtIndex:indexPath.row]; 
    
    //fare un metodo popola celle??
    
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
                cell.detailTextLabel.text = job.date;
            else if(row == 2)
                cell.detailTextLabel.text = @"";
            else if(row == 3)
                cell.detailTextLabel.text = job.city;
            
            break;
        case 1:
            if(row == 0)
                ((TextAreaCell*)cell).textView.text = job.description;
            break;
        case 2:
            if(row == 0){
                if(job.phone != nil && ! [job.phone isEqualToString:@""])
                    cell.detailTextLabel.text = job.phone;
                else cell.detailTextLabel.text = @"Non disponibile";
            }
            else if(row == 1){
                if(job.email != nil && ! [job.email isEqualToString:@""])
                    cell.detailTextLabel.text = job.email;
                else cell.detailTextLabel.text = @"Non disponibile";
            } 
            else if(row == 2){
                if(job.url != nil && ! [job.url isEqualToString:@""])
                    cell.detailTextLabel.text = job.url;
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
                NSString *number = [NSString stringWithFormat:@"%@%@", @"tell://", cell.detailTextLabel.text];
                //verificare sul device
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:number]];
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
                url = [NSURL URLWithString:cell.detailTextLabel.text];
                //this will open the selected URL into the safari
                [[UIApplication sharedApplication]openURL: url ]; 
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

-(void) setJob:(Job*) newJob{
    if(job != newJob){
        [newJob retain];
        [job release];
        job = newJob;
    }
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
                         @"",                 @"img",
                         nil] autorelease] atIndex: 0];
    [secA insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"InfoCell",         @"kind", 
                         @"Inserito il",      @"label",
                         @"",                 @"img",
                         nil] autorelease] atIndex: 1];
    
    [secA insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"InfoCell",         @"kind", 
                         @"Via",              @"label",
                         @"",                 @"img",
                         nil] autorelease] atIndex: 2];
    
    [secA insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"InfoCell",         @"kind", 
                         @"Città",            @"label",
                         @"",                 @"img",
                         nil]autorelease] atIndex: 3];
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
                         nil]autorelease] atIndex: 0];
    
    [secC insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"ActionCell",       @"kind",
                         @"Scrivi",           @"label",
                         @"",                 @"img",
                         nil] autorelease] atIndex: 1];
    
    [secC insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"ActionCell",       @"kind", 
                         @"Visita",           @"label",
                         @"",                 @"img",
                         nil]autorelease] atIndex: 2];
    
    sectionData = [[NSArray alloc] initWithObjects: secA, secB, secC, nil];
    sectionDescripition = [[NSArray alloc] initWithObjects:@"Informazioni generali", @"Descrizione", @"Contatti", nil];  
    
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
    [super dealloc];
}

@end
