//
//  CreditsViewController.m
//  jobFinder
//
//  Created by mario greco on 26/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CreditsViewController.h"
#import <MessageUI/MessageUI.h>
#import "BaseCell.h"

#define EMAIL_CONTACT_1 @"mrgreco3@gmail.com"
#define EMAIL_CONTACT_2 @"panizzi@uniroma1.it"
#define URL_INFO @"http://www.sapienzaapps.it/jobfinder/index.html"

@implementation CreditsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Table view data source

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
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{  
    return [sectionDescripition objectAtIndex:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Dipartimento di Informatica";
            break;
        case 1:
            return @"";
            break;
            
        default:
            return nil;
            break;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = indexPath.section;
    int row = indexPath.row;
    NSURL *url; 
    
    if(section == 2){
        switch (row) {
            case 0:
                NSLog(@"emaildidSelectRow");
                MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
                mail.mailComposeDelegate = self;
                
                if([MFMailComposeViewController canSendMail]){
                    [mail setToRecipients:[NSArray arrayWithObjects:EMAIL_CONTACT_1,EMAIL_CONTACT_2, nil]];
                    [mail setSubject:@"Email da JobNavigator"];
                    [mail setMessageBody:@"" isHTML:NO];
                    [self presentModalViewController:mail animated:YES];
                    [mail release];
                }
                break; 
            case 1:
                //NSLog(@"url didSelectRow");
                url = [NSURL URLWithString:URL_INFO];
                [[UIApplication sharedApplication]openURL: url ]; 
                break; 
                
        }
    }
    
    //deseleziona la cella
    [tableView deselectRowAtIndexPath:indexPath animated:YES];  
}

#pragma mark - MailComposerDelegate

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


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Credits"];
    //self.navigationItem.hidesBackButton = TRUE;
    //aggiungo bottone "fatto" alla barra e setto azione

    
    //creo le sezioni
    NSMutableArray *secB = [[NSMutableArray alloc] init];
    NSMutableArray *secC = [[NSMutableArray alloc] init];
    NSMutableArray *secD = [[NSMutableArray alloc] init];
    
        
    [secB insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"site",              @"DataKey",
                         @"InfoCell",          @"kind",
                         @"Prof. Emanuele Panizzi",  @"label",
                         @"",                  @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleValue1], @"style",
                         nil]autorelease] atIndex: 0];
    
    [secC insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"site",             @"DataKey",
                         @"InfoCell",         @"kind",
                         @"Mario Greco",      @"label",
                         @"",         @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleValue1], @"style",
                         nil]autorelease] atIndex: 0];
    
    [secD insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"email",            @"DataKey",
                         @"ActionCell",       @"kind",
                         @"Scrivici",       @"label",
                         @"mail.png",         @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleValue1], @"style",
                         nil] autorelease] atIndex: 0];
    
    [secD insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"site",             @"DataKey",
                         @"ActionCell",       @"kind",
                         @"Visitaci",   @"label",
                         @"home.png",                 @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleValue1], @"style",
                         nil]autorelease] atIndex: 1];
    
    
    
    sectionData = [[NSArray alloc] initWithObjects:secB, secC,secD, nil];
    sectionDescripition = [[NSArray alloc] initWithObjects:@"Supervisore",@"Sviluppatore",@"Contatti",nil];
    
    [secB autorelease];
    [secC autorelease];
    [secD autorelease];
    


    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [sectionData release];
    sectionData = nil;
    [sectionDescripition release];
    sectionDescripition = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



#pragma mark - MemoryManagament
-(void)dealloc
{
    [sectionData release];
    [sectionDescripition release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


@end
