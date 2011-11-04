//
//  FilterViewController.m
//  jobFinder
//
//  Created by mario greco on 30/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterViewController.h"

@implementation FilterViewController
@synthesize tableStructure, sections, structureFromPlist, plistName;

-(id) initWithPlist:(NSString *)plist
{
    self = [super initWithNibName:@"FilterViewController" bundle:nil];
    if(self){
        self.plistName = plist;
        aSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [aSwitch addTarget:self action:@selector(switchChanged) forControlEvents:UIControlEventValueChanged];
        aSwitch.on = NO;
        
    }
    return self;
    
}


#pragma mark - DataSourceDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    NSString *key = [sections objectAtIndex:indexPath.section];
    NSArray *valuesSection = [tableStructure objectForKey:key];
    NSDictionary *rowDesc = [valuesSection objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {        
        cell = [[[UITableViewCell alloc ]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        NSLog(@"ALLOCATA cella %p",cell);
    }
    else{
        NSLog(@"RICICLO cella %p",cell);
    }
    
    
    
    if(indexPath.section == 0){
        cell.textLabel.text = @"Filtro";
        cell.accessoryView = aSwitch;      
    }
    else{
        cell.textLabel.text = [rowDesc objectForKey:@"label"];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.accessoryView = nil;
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{  
    return [sections objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    NSString *key=[sections objectAtIndex:section];
    NSArray *values = [tableStructure  objectForKey:key];
    return [values count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sections.count;
}

#warning pulire if-if
#pragma mark - Table view delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{    
//    if(firsTime){
//        indexPathSelected = indexPath;
//        firsTime = FALSE;
//        [tableView cellForRowAtIndexPath:indexPath].accessoryType = 
//        UITableViewCellAccessoryCheckmark;
//        [selectedCells replaceObjectAtIndex:indexPath.row 
//                                 withObject:@"selected"];
//    }
//    
//    if(indexPath.row != indexPathSelected.row){
//        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
//        [selectedCells replaceObjectAtIndex:indexPath.row 
//                                 withObject:@"selected"];
//        [tableView cellForRowAtIndexPath:indexPathSelected].accessoryType = UITableViewCellAccessoryNone;
//        [selectedCells replaceObjectAtIndex:indexPathSelected.row 
//                                 withObject:@"noSelected"];
//        // [selectedCells insertObject:@"notSelected" atIndex:indexPath.row];
//        indexPathSelected = indexPath;
//    }
//    
//    selectedCell = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
//    [filtDelegate didSelectedFilterFromTable:selectedCell];   
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"employeeDidSet" object:self userInfo:nil]; 
//    
//    [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
//}

-(void)switchChanged
{
    NSLog(@"SWITCH CAMBIATO");
    
    if(aSwitch.on){
        
        //cambio il model aggiungendogli le informazioni sulle nuove sezioni e celle
        for(int i = 1; i < structureFromPlist.count;i++){
            NSDictionary *tempDict = [structureFromPlist objectAtIndex:i];   
            //NSLog(@"++++++ TEMP DICTIO %@",tempDict);
            
            [tableStructure addEntriesFromDictionary:tempDict];
        //    NSLog(@"Table structure content = %@",tableStructure);
        }
        
        NSArray *tempArray = [[tableStructure allKeys] sortedArrayUsingSelector:@selector(compare:)];
    //    NSLog(@"***** TEMP ARRAY = %@",tempArray);
    //    NSLog(@"***** SECTIONS = %@",sections);
       
        //aggiungo  all'array che contiene i nomi delle sezioni le nuove sezioni
        [self.sections addObjectsFromArray:tempArray];
        //NSLog(@"***** TEMP ARRAY = %@",tempArray);
    //    NSLog(@"####### SECTIONS = %@",sections);
        //rimuovo ultimo elemento che è la ripetizione del nome della prima sezione
        [self.sections removeObjectAtIndex: sections.count - 1 ];
    //     NSLog(@"*@@@@@@ SECTIONS = %@",sections);                                                  

//        NSLog(@"*@@@@@@ Table structure content = %@",tableStructure);
//        NSLog(@"*@@@@@@ SECTIONS = %@",sections);

        
        NSRange range;
        //imposto il range per le nuove sezioni da inserire nella tableView
        range.location = 1;
        range.length = sections.count - 1;
        [self.tableView beginUpdates];
        //[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:YES];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:range] withRowAnimation:YES];
        //[self.tableView insertSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:YES];
        [self.tableView endUpdates];
    }
    else{
        //eliminare dal model tutte le sezioni tranne la prima e rifare l'update
    }
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //recupero path del file plist
    NSString *plisStructure = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    //recupero array
    self.structureFromPlist = [NSArray arrayWithContentsOfFile:plisStructure];
    
    //struttura della tabella composta da una sola sezione e una sola cella (il primo dizionario)
    self.tableStructure = [[NSMutableDictionary alloc] initWithDictionary:[structureFromPlist objectAtIndex:0]]; 
    
    //creao array di settori indicizzati e in ordine alfabetico (0=A,1=B,...)
    NSArray *tempArray = [[tableStructure allKeys] sortedArrayUsingSelector:@selector(compare:)];
    self.sections  = [[NSMutableArray alloc] initWithArray:tempArray];

//    NSLog(@"*****************************************************");
//    NSLog(@"Table structure TYPE = %@",[tableStructure class]);
//
//    NSLog(@"TABLE STRUCTURE = %@",tableStructure);
//    NSLog(@"SECTIONS = %@",sections);
//    NSLog(@"*****************************************************");

    self.title = @"Imposta filtro";//[[structureFromPlist objectAtIndex:0] objectForKey:@"name"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void) dealloc
{
    [aSwitch release];
    [rowInSection release];
    [tableStructure release];
    [sections release];
    [super dealloc];
    
}
@end


