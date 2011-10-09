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
//@synthesize job;

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
    NSString *dataKey = [rowDesc objectForKey:@"DataKey"];
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    //setto il tipo di tastiera per il texfield se la cella è di tipo editabile
    if ([[rowDesc objectForKey:@"kind"] isEqualToString:@"TextFieldCell"]) {
      
        //configuro i texfield
        ((TextFieldCell *) cell).textField.placeholder =
                                            [rowDesc objectForKey:@"placeholder"];
        ((TextFieldCell *) cell).dataKey = dataKey;
        NSString * kt = [rowDesc objectForKey:@"keyboardType"];
        NSInteger kti = [kt integerValue];
        ((TextFieldCell *)cell).textField.keyboardType = kti;
    }
    else if([[rowDesc objectForKey:@"kind"] isEqualToString:@"TextAreaCell"]){
        ((TextAreaCell *) cell).dataKey = dataKey;
        ((TextAreaCell *) cell).textView.text = [rowDesc objectForKey:@"placeholder"];
    }
    else cell.detailTextLabel.text = [rowDesc objectForKey:@"placeholder"];

    //forzare utente ad inserire http oppure effettuare il controllo altrove e se nn c'è inserirlo?
//    if(indexPath.section == 2 && indexPath.row == 2)
//        ((TextFieldCell*) cell).textField.text = @"http://";
    
    
    [cell setDelegate:self];
    
    return cell;    
}


//ATTENZIONE: faccio il release del job nel metodo dealloc, ma non sono sicuro se è giusto e cosa accade una volta che tale job lo passo ad altre view. viene copiato? retain + 1?


//azioni per le celle selezionate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    int section = indexPath.section;
    int row = indexPath.row;
//    NSURL *url; 
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
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
        
        //inizializzo la cella al primo elemento del picker
        cell.detailTextLabel.text = pickerView.jobCategory;
    }
    

    
    //deseleziona cella
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];  
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
        job.url = txtField.text;    
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

#pragma mark - ActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{   
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
   
    if(pickerView.jobCategory != nil)
        cell.detailTextLabel.text = pickerView.jobCategory;
    else cell.detailTextLabel.text = @"Scegli...";
    
    //salvo dato preso dal picker dentro job
    job.employee = pickerView.jobCategory;
 //   NSLog(@"EDITA_TABLE: job.employee = %@",job.employee);
//    NSLog(@"job puntatore: %p",job);
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
     
     job = [[Job alloc]init];
     job.date = @"09/10/2011";

     NSMutableArray *secA = [[NSMutableArray alloc] init];
     NSMutableArray *secB = [[NSMutableArray alloc] init];
     NSMutableArray *secC = [[NSMutableArray alloc] init];
     
     [secA insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                          @"employee",         @"DataKey",
                          @"InfoCell",         @"kind", 
                          @"Impiego",          @"label",
                          @"Scegli...",        @"placeholder",
                          @"",                 @"img",
                          nil] autorelease] atIndex: 0];
     
     [secB insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                          @"description",      @"DataKey",
                          @"TextAreaCell",     @"kind",
                          @"Descrizione",      @"label",
                          @"Inserisci qui una breve descrizione",  @"placeholder",
                          @"",                 @"img",
                          [NSString stringWithFormat:@"%d", UIKeyboardTypeDefault], @"keyboardType",
                          nil] autorelease]  atIndex: 0];
     
     [secC insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                          @"phone",            @"DataKey",
                          @"TextFieldCell",    @"kind",
                          @"Telefono",         @"label",
                          @"44112233",         @"placeholder",
                          @"",                 @"img",
                          [NSString stringWithFormat:@"%d", UIKeyboardTypeNumbersAndPunctuation], @"keyboardType",
                          nil] autorelease ]  atIndex: 0];
     
     [secC insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                          @"email",            @"DataKey",
                          @"TextFieldCell",    @"kind",
                          @"E-mail",           @"label",
                          @"esempio@mail.com", @"placeholder",
                          @"",                 @"img",
                          [NSString stringWithFormat:@"%d", UIKeyboardTypeEmailAddress], @"keyboardType",
                          nil] autorelease] atIndex: 1];
     
     [secC insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                          @"url",              @"DataKey",
                          @"TextFieldCell",    @"kind", 
                          @"URL",              @"label", 
                          @"http://www.esempio.com",  @"placeholder",
                          @"",                 @"img", 
                          [NSString stringWithFormat:@"%d", UIKeyboardTypeURL], @"keyboardType", 
                          nil] autorelease] atIndex: 2];
     
     
     // non li rilascio perchè usano initWithObject, quindi è rimandato a super
     sectionData = [[NSArray alloc] initWithObjects: secA, secB, secC, nil];
     sectionDescripition = [[NSArray alloc] initWithObjects:@"Informazioni generali", @"Descrizione", @"Contatti", nil];   
     
     [secA autorelease]; //autorelease??
     [secB autorelease];
     [secC autorelease];

 }

//- (void) viewWillDisappear:(BOOL) animated
//{
//    //invio al delegato il job
////    [[self delegate] setJobCollected:job];
//}

- (void)viewDidUnload
{
    //NSLog(@"ECCOLO");
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
    [pickerView release]; //crasha_vecchio
    [actionSheet release];

//    NSLog(@"dea job = %p, count = %d",job, job.retainCount);
}

#pragma mark - to do list
//TODO 1: validazione input
//TODO 2: se un texfield non viene selezionato mai e si preme "inserisci" il campo salvato nel job sarà NULL, se invece si seleziona almeno una volta e si lascia bianco sarà @""--> UNIFORMARE
//TODO 3: la textview se non viene mai selezionata sarà NULL nel job.description, mente se selezionata almeno una volta sarà @"Inserire qui una breve descrizione" --> CORREGGERE
//TODO 4: tasto inserisci grigio finchè non si è scelta la categoria!
//TODO 5: riuso celle
//TODO 6: nella validazione dell'input inserire http:// se non presente davanti l'url
@end
