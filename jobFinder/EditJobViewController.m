//
//  EditJobViewController.m
//  jobFinder
//
//  Created by mario greco on 03/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EditJobViewController.h"
#import "PickerViewController.h"

@implementation EditJobViewController
@synthesize job /*, delegate, pickerView*/;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        NSMutableArray *secA = [[NSMutableArray alloc] init];
        NSMutableArray *secB = [[NSMutableArray alloc] init];
        NSMutableArray *secC = [[NSMutableArray alloc] init];
        
        [secA insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                            @"employee",         @"DataKey",
                            @"UITableViewCell",  @"kind", 
                            @"Impiego",          @"label",
                            @"",                 @"img",
                            [NSString stringWithFormat:@"%d",UIKeyboardTypeDefault], @"keyboardType",
                            nil] autorelease] atIndex: 0];
        
        [secB insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                            @"description",      @"DataKey",
                            @"TextAreaCell",     @"kind",
                            @"Descrizione",      @"label",
                            @"",                 @"img",
                            [NSString stringWithFormat:@"%d", UIKeyboardTypeDefault], @"keyboardType",
                            nil] autorelease]  atIndex: 0];
        
        [secC insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                            @"phone",            @"DataKey",
                            @"TextFieldCell",    @"kind",
                            @"Telefono",         @"label",
                            @"",                 @"img",
                            [NSString stringWithFormat:@"%d", UIKeyboardTypeNumbersAndPunctuation], @"keyboardType",
                            nil] autorelease ]  atIndex: 0];
        
        [secC insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                            @"email",            @"DataKey",
                            @"TextFieldCell",    @"kind",
                            @"E-mail",           @"label",
                            @"",                 @"img",
                            [NSString stringWithFormat:@"%d", UIKeyboardTypeEmailAddress], @"keyboardType",
                            nil] autorelease] atIndex: 1];
        
        [secC insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                            @"url",              @"DataKey",
                            @"TextFieldCell",    @"kind", 
                            @"URL",              @"label", 
                            @"",                 @"img", 
                            [NSString stringWithFormat:@"%d", UIKeyboardTypeURL], @"keyboardType", 
                            nil] autorelease] atIndex: 2];
        
        sectionData = [[NSArray alloc] initWithObjects: secA, secB, secC, nil];
        sectionDescripition = [[NSArray alloc] initWithObjects:@"Informazioni generali", @"Descrizione", @"Contatti", nil];   
        
        [secA autorelease]; //autorelease??
        [secB autorelease];
        [secC autorelease];
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
    NSString *dataKey = [rowDesc objectForKey:@"DataKey"];
    
    //setto il tipo di tastiera per il texfield se la cella è di tipo editabile
    if ([[rowDesc objectForKey:@"kind"] isEqualToString:@"TextFieldCell"]) {
//        ((TextFieldCell *) cell).textField.delegate = self;
        NSString * kt = [rowDesc objectForKey:@"keyboardType"];
        NSInteger kti = [kt integerValue];
        //        NSLog(@"%@/%@", kt, [NSString stringWithFormat:@"%d", UIKeyboardTypeURL]);
        ((TextFieldCell *)cell).textField.keyboardType = kti;
        ((TextFieldCell *) cell).dataKey = dataKey;
    }
    else if([[rowDesc objectForKey:@"kind"] isEqualToString:@"TextAreaCell"]){
//        ((TextAreaCell *) cell).textView.delegate = self;
        ((TextAreaCell *) cell).dataKey = dataKey;
    }
                         
    [cell setDelegate:self];
    
    return cell;    
}


//ATTENZIONE: faccio il release del job nel metodo dealloc, ma non sono sicuro se è giusto e cosa accade una volta che tale job lo passo ad altre view. viene copiato? retain + 1?

- (void)textFieldDidEndEditing:(UITextField *)txtField
{
    //recupera la cella relativa al texfield
    TextFieldCell *cell = (TextFieldCell *) [[txtField superview] superview];
    
//    NSLog(@"2) dataKey %@, texField %@", cell.dataKey, cell.textField.text);

    if([cell.dataKey isEqualToString:@"employee"])
        job.employee = txtField.text;
    else if([cell.dataKey isEqualToString:@"phone"])
        job.phone = txtField.text;
    else if([cell.dataKey isEqualToString:@"email"])
        job.email = txtField.text;    
    else if([cell.dataKey isEqualToString:@"url"])
        job.url = txtField.text;    
    
}

-(void) textViewDidEndEditing:(UITextView *)textView
{    
    TextAreaCell *cell = (TextAreaCell *) [textView superview] ;
//     NSLog(@"2) dataKey %@, textArea %@ ", cell.dataKey, cell.textView.text);
    if ([cell.dataKey isEqualToString:@"description"])
        job.description = textView.text;
}

//azioni per le celle selezionate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int section = indexPath.section;
    int row = indexPath.row;
//    NSURL *url; 
    
    if(section == 0 && row == 0){
        
        //creo actionSheet con un solo tasto custom
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Prova" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:@"Seleziona", nil];
        //setto il frame NN CE NE è BISOGNO; PERCHé???
//        [actionSheet setFrame:CGRectMake(0, 117, 320, 383)];
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        //imposto questo controller come delegato dell'actionSheet
        [actionSheet setDelegate:self];
        [actionSheet showInView:self.view];
        //setto i bounds dell'action sheet in modo tale da contenere il picker
        [actionSheet setBounds:CGRectMake(0,0,320, 500)]; 
        
        //array contenente le subviews dello sheet (sono 2, il titolo e il bottone custom
        NSArray *subviews = [actionSheet subviews];
        //setto il frame del tasto così da mostrarlo sotto al picker
        //1 lo passo a mano, MODIFICARE
        [[subviews objectAtIndex:1] setFrame:CGRectMake(20, 255, 280, 46)]; 
        pickerView = [[PickerViewController alloc] init];
        [actionSheet addSubview: pickerView.view];

        
//        NSLog(@"cliccato riga 0");
    }
    
    //deseleziona cella
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];  
    
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
     job = [[Job alloc]init];
     NSLog(@"EDIT_TABLE: job = %p, count = %d",job, job.retainCount);

     [super viewDidLoad];
 }

//- (void) viewWillDisappear:(BOOL) animated
//{
//    //invio al delegato il job
////    [[self delegate] setJobCollected:job];
//}

- (void)viewDidUnload
{
    NSLog(@"ECCOLO");
    [super viewDidUnload];
    pickerView = nil;
    actionSheet = nil;
    //    NSLog(@"UIPIKER UNLOAD count = %d", pickerView.view.retainCount);
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
    [job release];
    NSLog(@"UIPIKER DEALLOC count = %d, address = %p", pickerView.retainCount, pickerView);
    
    [pickerView release]; //crasha_vecchio
    [actionSheet release];

//    NSLog(@"dea job = %p, count = %d",job, job.retainCount);
}

@end
