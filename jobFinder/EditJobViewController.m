//
//  EditJobViewController.m
//  jobFinder
//
//  Created by mario greco on 03/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.


#import "EditJobViewController.h"
#import "SectorTableViewController.h"
#import "ActionCell.h"
#import "TextFieldCell.h"
#import "TextAreaCell.h"

@implementation EditJobViewController
@synthesize fields;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        
    }
    return self;
}


#pragma mark - DataSourceProtocol

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sec = [sectionData objectAtIndex:indexPath.section];
    NSDictionary *rowDesc = [sec objectAtIndex:indexPath.row]; 
    
    BaseCell *cell = (BaseCell*)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    [self fillCell:cell rowDesc:rowDesc];
    
    [cell setDelegate:self];
    
    return cell;    
}


#pragma mark - TableViewDelegate

//azioni per le celle selezionate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int section = indexPath.section;
    int row = indexPath.row;
    
    if(section == 0 && row == 0){

        SectorTableViewController *sectorTable = [[SectorTableViewController alloc] initWithPlist:@"sector-table"];
        sectorTable.secDelegate = self;
        [self.navigationController pushViewController:sectorTable animated:YES];
        [sectorTable release];
    }
    else if(section == 2){
        TextFieldCell *cell = (TextFieldCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell.textField becomeFirstResponder];
    }
}


#pragma mark - TextField and TextView Delegate

- (void)textFieldDidEndEditing:(UITextField *)txtField
{   
    //recupera la cella relativa al texfield
    TextFieldCell *cell = (TextFieldCell *) [[txtField superview] superview];

    if([cell.dataKey isEqualToString:@"phone"])
        job.phone = txtField.text;
    else if([cell.dataKey isEqualToString:@"email"])
        job.email = txtField.text;    
    else if([cell.dataKey isEqualToString:@"url"])
        [job setUrlWithString:txtField.text];    
}

-(void) textViewDidEndEditing:(UITextView *)textView
{    
    TextAreaCell *cell = (TextAreaCell *) [textView superview] ;
    //     NSLog(@"2) dataKey %@, textArea %@ ", cell.dataKey, cell.textView.text);
    if ([cell.dataKey isEqualToString:@"description"])
        job.description = textView.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{ 
	[textField resignFirstResponder];
	return YES;
}

#pragma mark - SectorTableDelegate

//prende i dati dalla tabella settori ed aggiorna la cella con il nuovo dato
-(void) didReceiveSectorFromTable:(NSString*) jobSector
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    NSString *placeholder;
    
    if(jobSector != nil){
        job.employee = jobSector;
        placeholder = jobSector;
    }    
    else{
        job.employee = @"";
        placeholder = @"Scegli...";
    } 
    
    //aggiorno il model della tabella
    [[[sectionData objectAtIndex:0] objectAtIndex:0] setObject:placeholder forKey:@"placeholder"];
    [self.tableView reloadRowsAtIndexPaths: [[[NSArray alloc] initWithObjects:indexPath,nil] autorelease] withRowAnimation:UITableViewRowAnimationNone];
    
    [self.navigationController popViewControllerAnimated:YES];
}

//riempe le celle in base ai dati del job creato
-(void)fillCell: (UITableViewCell *)cell rowDesc:(NSDictionary *)rowDesc
{
    NSString *datakey= [rowDesc objectForKey:@"DataKey"];
    
    if([datakey isEqualToString:@"employee"]){
         cell.detailTextLabel.text = job.employee;
        if(job.employee == nil || [job.employee isEqualToString:@""])
            ((ActionCell *)cell).detailTextLabel.text = [rowDesc objectForKey:@"placeholder"];
        else ((ActionCell *)cell).detailTextLabel.text = job.employee;
    }
    else if([datakey isEqualToString:@"description"])
        ((TextAreaCell*)cell).textView.text = job.description;
    else if([datakey isEqualToString:@"phone"])
         ((TextFieldCell *)cell).textField.text = job.phone;
    else if([datakey isEqualToString:@"email"])
         ((TextFieldCell *)cell).textField.text = job.email;
    else if([datakey isEqualToString:@"url"])
         ((TextFieldCell *)cell).textField.text = [job.url absoluteString]; 
}

- (void)hideKeyboard 
{
//    TextAreaCell *cell = 

    //NSLog(@"SUBVIEW = %@", [self.view viewWithTag:1111] );
    
    if([self.tableView viewWithTag:1111] != nil)
        [[self.tableView viewWithTag:1111] resignFirstResponder];
}
    

#pragma mark - View lifecycle

//questa view può esser ruotata
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad
 {   
     [super viewDidLoad];
     
//     job = [[Job alloc]initWithCoordinate:CLLocationCoordinate2DMake(0,0)];
     //NSLog(@"job in EDTI_VIEW: %p",job);
     
     
     //creo il model della tabella
     NSMutableArray *secA = [[NSMutableArray alloc] init];
     NSMutableArray *secB = [[NSMutableArray alloc] init];
     NSMutableArray *secC = [[NSMutableArray alloc] init];
     
     [secA insertObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:
                          @"employee",         @"DataKey",
                          @"ActionCell",       @"kind", 
                          @"Settore",          @"label",
                          @"Scegli...",        @"placeholder",
                          @"",                 @"img",
                          [NSString stringWithFormat:@"%d", UITableViewCellStyleValue1], @"style",
                          nil] autorelease] atIndex: 0];
     
     [secB insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                          @"description",      @"DataKey",
                          @"TextAreaCell",     @"kind",
                          @"Descrizione",      @"label",
                          @"",                 @"placeholder",
                          @"",                 @"img",
                          [NSString stringWithFormat:@"%d", UITableViewCellStyleValue1], @"style",
                          [NSString stringWithFormat:@"%d", UIKeyboardTypeDefault], @"keyboardType",
                          nil] autorelease]  atIndex: 0];
     
     [secC insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                          @"phone",            @"DataKey",
                          @"TextFieldCell",    @"kind",
                          @"Telefono",         @"label",
                          @"44112233",         @"placeholder",
                          @"",                 @"img",
                          [NSString stringWithFormat:@"%d", UITableViewCellStyleValue1], @"style",
                          [NSString stringWithFormat:@"%d", UIKeyboardTypeNumbersAndPunctuation], @"keyboardType",
                          nil] autorelease ]  atIndex: 0];
     
     [secC insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                          @"email",            @"DataKey",
                          @"TextFieldCell",    @"kind",
                          @"E-mail",           @"label",
                          @"esempio@mail.com", @"placeholder",
                          @"",                 @"img",
                          [NSString stringWithFormat:@"%d", UITableViewCellStyleValue1], @"style",
                          [NSString stringWithFormat:@"%d", UIKeyboardTypeEmailAddress], @"keyboardType",
                          nil] autorelease] atIndex: 1];
     
     [secC insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                          @"url",              @"DataKey",
                          @"TextFieldCell",    @"kind", 
                          @"URL",              @"label", 
                          @"http://www.esempio.com",  @"placeholder",
                          @"",                 @"img", 
                          [NSString stringWithFormat:@"%d", UITableViewCellStyleValue1], @"style",
                          [NSString stringWithFormat:@"%d", UIKeyboardTypeURL], @"keyboardType", 
                          nil] autorelease] atIndex: 2];
     
     
     //il release è lasciato alla classe madre
     sectionData = [[NSArray alloc] initWithObjects: secA, secB, secC, nil];
     sectionDescripition = [[NSArray alloc] initWithObjects:@"Informazioni generali", @"Descrizione", @"Contatti", nil];   
     
     [secA autorelease]; //autorelease??
     [secB autorelease];
     [secC autorelease];
     
     UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
     [self.tableView addGestureRecognizer:gestureRecognizer];
     gestureRecognizer.cancelsTouchesInView = NO;  // this prevents the gesture recognizers to 'block' touches
     [gestureRecognizer release];

 }

//- (void) viewWillDisappear:(BOOL) animated
//{
//    //invio al delegato il job
////    [[self delegate] setJobCollected:job];
//}

- (void)viewDidUnload
{
    [sectionDescripition release];
    sectionDescripition = nil;
    [sectionData release];
    sectionData = nil;
    //NSLog(@"ECCOLO");
    [super viewDidUnload];
    
    //    NSLog(@"UIPIKER UNLOAD count = %d", pickerView.view.retainCount);
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
    [job release]; //aggiunti 19 novembre
    job = nil; 
    [super dealloc];

//    NSLog(@"dea job = %p, count = %d",job, job.retainCount);
}


@end
