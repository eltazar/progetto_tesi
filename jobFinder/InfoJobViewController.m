//
//  InfoJobViewController.m
//  jobFinder
//
//  Created by mario greco on 03/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InfoJobViewController.h"

@implementation InfoJobViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
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
                            @"Via",              @"label",
                            @"",                 @"img",
                            nil] autorelease] atIndex: 1];
        
        [secA insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                            @"InfoCell",         @"kind", 
                            @"Città",            @"label",
                            @"",                 @"img",
                            nil]autorelease] atIndex: 2];
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
    
    
    //    if([[rowDesc objectForKey:@"kind"] isEqualToString:@"InfoCell"]){
    //        //recupera i dati dall'oggetto Job e popola le celle Impiego, Zona e Descrizione    
    //        //prova
    //        if(indexPath.row == 0)
    //            cell.detailTextLabel.text = job.employe;
    //        else if(indexPath.row == 1)
    //            cell.detailTextLabel.text = job.email;
    //
    //    }
    
    [self fillCell:cell InRow:indexPath.row inSection:indexPath.section];
    
//    if([[rowDesc objectForKey:@"kind"] isEqualToString:@"ActionCell"]){
//        //rendo la cella selezionabile (diventa blu)
//        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
//        //prova
//        //        cell.detailTextLabel.text = @"bhoooo";
//        
//        //TODO: aggiungere immagine alla cella
//    }
    
    if([[rowDesc objectForKey:@"kind"] isEqualToString:@"TextAreaCell"])
        //rendo la cella non editabile
        ((TextAreaCell *)cell).textView.editable = NO;
    
    return cell;
}    

/*forse questo è il modo più semplice/efficiente per riempire ogni riga della tabella job.
 *quindi forse conviene fare un metodo in Job che ritorna l'array di tutti i suoi attributi,
 * in modo da avere i suoi campi indicizzati in base al numero delle righe della tabella.
 */
-(void) fillCell:(UITableViewCell*)cell InRow:(int)row inSection:(int)section
{
    //PASSARE UN JOB!!!!
    
    //    NSLog(@"job array count = %d",jobArray.count);
//    NSLog(@"row = %d, section = %d", row, section);
//    static int arrayIndex = 0;
//    NSLog(@"arrayIndex inizio metodo = %d",arrayIndex);
//    
//    
//    if([[jobArray objectAtIndex:arrayIndex] isEqualToString:@""])
//        cell.detailTextLabel.text = @"Non disponibile";       
//    else    cell.detailTextLabel.text = [jobArray objectAtIndex:arrayIndex];
//    
//    
//    //TODO: come settare il campo textView della descrizione? :S
//    
//    ++arrayIndex;
//    NSLog(@"arrayIndex fine metodo = %d",arrayIndex);
//    if(arrayIndex == [jobArray count])
//        arrayIndex = 0;
//    
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
