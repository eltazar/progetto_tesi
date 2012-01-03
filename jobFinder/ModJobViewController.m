//
//  ModJobViewController.m
//  jobFinder
//
//  Created by mario greco on 02/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ModJobViewController.h"
#import "EditJobViewController.h"
#import "SectorTableViewController.h"
#import "ActionCell.h"
#import "TextFieldCell.h"
#import "TextAreaCell.h"
#import "Utilities.h"

@implementation ModJobViewController
@synthesize delegate;

-(id)initWithJob:(Job*)theNewJob{
    
    
    self = [super initWithNibName:@"RootJobViewController" bundle:nil];
    
    if(self){
        self.job = theNewJob;
        NSLog(@"INIT WITH JOB MOD = %p, thenew = %p",job,theNewJob);
        // Custom initialization
        segmentedCtrl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Part-time",@"Full-time", nil]];       
        segmentedCtrl.frame = CGRectMake(27, 7, 180, 30);
        [segmentedCtrl addTarget:self
                          action:@selector(selectedTime:)
                forControlEvents:UIControlEventValueChanged];
        segmentedCtrl.segmentedControlStyle = UISegmentedControlStyleBar;
        if([theNewJob.time isEqualToString:@"Part-time"])
           [segmentedCtrl setSelectedSegmentIndex:0];
        else if([theNewJob.time isEqualToString:@"Full-time"])
            [segmentedCtrl setSelectedSegmentIndex:1];
    }
    
    return self;
    
}

#pragma mark - DataSourceProtocol


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sec = [sectionData objectAtIndex:indexPath.section];
    NSDictionary *rowDesc = [sec objectAtIndex:indexPath.row]; 
    
    BaseCell *cell = (BaseCell*)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if(indexPath.section == 0 && indexPath.row == 1){
        
        cell.accessoryView = segmentedCtrl;
        //[cell.contentView addSubview:segmentedCtrl]; 
        cell.selectionStyle = UITableViewCellSelectionStyleNone;        
    }
    
    [self fillCell:cell rowDesc:rowDesc];
    
    [cell setDelegate:self];
    
    return cell;    
}


#pragma mark - TableViewDelegate


// Notice: this will work only for one section within the table view

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if(section == 3){
        // create the parent view that will hold 1 or more buttons
        UIView* v = [[UIView alloc] initWithFrame:CGRectMake(10.0, 0.0, 300.0, 44.0)];
        
        // create the button object
        UIButton* b = [UIButton buttonWithType:UIButtonTypeCustom];
        [b setBackgroundImage:[[UIImage imageNamed:@"cancelButton.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0] forState:UIControlStateNormal];
        
        b.frame = CGRectMake(10.0, 0.0, 300.0, 44.0);
        [b setTitle:@"Cancella offerta" forState:UIControlStateNormal];
        
        // give it a tag in case you need it later
        //b.tag = 1;
        
        // this sets up the callback for when the user hits the button
        [b addTarget:self action:@selector(cancelBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        // add the button to the parent view
        [v addSubview:b];
        
        return [v autorelease];
    }

    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView   heightForFooterInSection:(NSInteger)section {
    
    if(section == 3)
        return 46;
    else return 0;
}


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
        [job _setPhone:txtField.text  kind:@"phone"];
    else if([cell.dataKey isEqualToString:@"phone2"])
        [job _setPhone:txtField.text kind:@"phone2"];
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
-(void) didReceiveSectorFromTable:(NSString*) jobSector andCode:(NSString*)code
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    NSString *placeholder;
    
    if(jobSector != nil){
        job.field = jobSector;
        placeholder = jobSector;
        job.code = code;
    }    
    else{
        job.field = @"";
        placeholder = @"Scegli...";
        job.code = @"";
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
        cell.detailTextLabel.text = job.field;
        if(job.field == nil || [job.field isEqualToString:@""])
            ((ActionCell *)cell).detailTextLabel.text = [rowDesc objectForKey:@"placeholder"];
        else ((ActionCell *)cell).detailTextLabel.text = job.field;
    }
    else if([datakey isEqualToString:@"description"])
        ((TextAreaCell*)cell).textView.text = job.description;
    else if([datakey isEqualToString:@"phone"])
        ((TextFieldCell *)cell).textField.text = job.phone;
    else if([datakey isEqualToString:@"phone2"])
        ((TextFieldCell *)cell).textField.text = job.phone2;
    else if([datakey isEqualToString:@"email"])
        ((TextFieldCell *)cell).textField.text = job.email;
    else if([datakey isEqualToString:@"url"])
        ((TextFieldCell *)cell).textField.text = [job.url absoluteString]; 
}

- (void)hideKeyboard 
{ 
    //nasconde tastiera se ho selezionato la cella contentente la textView
    if([self.tableView viewWithTag:1111] != nil)
        [[self.tableView viewWithTag:1111] resignFirstResponder];
}

- (void) selectedTime:(id)sender{
    NSLog(@"SELECTOR");
    switch(segmentedCtrl.selectedSegmentIndex)
    {
        case 0:
            job.time = @"Part-time";
            break;
        case 1:
            job.time = @"Full-time";
            break;
        default: job.time = @"";
            break;
    }
    
    NSLog(@"job.time = %@",job.time);
}

#pragma mark - Gestione azioni bottoni view

-(void)cancelBtnClicked:(id)sender{
    
    if(delegate && [delegate respondsToSelector:@selector(didDeletedJob:)])
        [delegate didDeletedJob:self];
}

#pragma mark - View lifecycle

//questa view può esser ruotata
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    NSLog(@"WILL JOB = %p",job);
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{   
    [super viewDidLoad];
    
    //     job = [[Job alloc]initWithCoordinate:CLLocationCoordinate2DMake(0,0)];
    NSLog(@"job in MOD: %p",job);
    
    [self.navigationItem setTitle:@"Modifica lavoro"];    
    //creo il model della tabella
    NSMutableArray *secA = [[NSMutableArray alloc] init];
    NSMutableArray *secB = [[NSMutableArray alloc] init];
    NSMutableArray *secC = [[NSMutableArray alloc] init];
    NSMutableArray *secD = [[NSMutableArray alloc] init];
        
    [secA insertObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:
                         @"employee",         @"DataKey",
                         @"ActionCell",       @"kind", 
                         @"Settore",          @"label",
                         [Utilities sectorFromCode:job.code],        @"placeholder",
                         @"",                 @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleValue1], @"style",
                         nil] autorelease] atIndex: 0];
    
    [secA insertObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:
                         @"time",             @"DataKey",
                         @"BaseCell",         @"kind", 
                         @"Contratto",                 @"label",
                         @"",                 @"placeholder",
                         @"",                 @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleDefault], @"style",
                         nil] autorelease] atIndex: 1];
    
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
                         @"Telefono 1",         @"label",
                         @"44112233",         @"placeholder",
                         @"",                 @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleValue1], @"style",
                         [NSString stringWithFormat:@"%d", UIKeyboardTypeNumbersAndPunctuation], @"keyboardType",
                         nil] autorelease ]  atIndex: 0];
    
    [secC insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"phone2",            @"DataKey",
                         @"TextFieldCell",    @"kind",
                         @"Telefono 2",         @"label",
                         @"44112233",         @"placeholder",
                         @"",                 @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleValue1], @"style",
                         [NSString stringWithFormat:@"%d", UIKeyboardTypeNumbersAndPunctuation], @"keyboardType",
                         nil] autorelease ]  atIndex: 1];
    
    [secC insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"email",            @"DataKey",
                         @"TextFieldCell",    @"kind",
                         @"E-mail",           @"label",
                         @"esempio@mail.com", @"placeholder",
                         @"",                 @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleValue1], @"style",
                         [NSString stringWithFormat:@"%d", UIKeyboardTypeEmailAddress], @"keyboardType",
                         nil] autorelease] atIndex: 2];
    
    [secC insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"url",              @"DataKey",
                         @"TextFieldCell",    @"kind", 
                         @"URL",              @"label", 
                         @"http://www.esempio.com",  @"placeholder",
                         @"",                 @"img", 
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleValue1], @"style",
                         [NSString stringWithFormat:@"%d", UIKeyboardTypeURL], @"keyboardType", 
                         nil] autorelease] atIndex: 3];
    
    
    //il release è lasciato alla classe madre
    sectionData = [[NSArray alloc] initWithObjects: secA, secB, secC,secD, nil];
    sectionDescripition = [[NSArray alloc] initWithObjects:@"Informazioni generali", @"Descrizione", @"Contatti",@"", nil];   
    
    [secA autorelease]; 
    [secB autorelease];
    [secC autorelease];
    [secD autorelease];
    
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
    [segmentedCtrl release];
    [job release]; //aggiunti 19 novembre
    job = nil; 
    [super dealloc];
    
    //    NSLog(@"dea job = %p, count = %d",job, job.retainCount);
}


@end
