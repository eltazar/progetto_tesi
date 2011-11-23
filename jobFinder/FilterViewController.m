//
//  FilterViewController.m
//  jobFinder
//
//  Created by mario greco on 30/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterViewController.h"

@implementation FilterViewController
@synthesize tableStructure, sections, structureFromPlist, plistName, selectedCells, indeces;

-(id) initWithPlist:(NSString *)plist
{
    self = [super initWithNibName:@"FilterViewController" bundle:nil];
    if(self){
        self.plistName = plist;
        aSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        [aSwitch addTarget:self action:@selector(switchChanged) forControlEvents:UIControlEventValueChanged];
        aSwitch.on = NO;
        //NSLog(@"init");
    }
    return self;
    
}


#pragma mark - DataSourceDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@"cell for row");
    
    static NSString *CellIdentifier = @"cell";
    NSString *key = [sections objectAtIndex:indexPath.section];
    NSArray *valuesSection = [tableStructure objectForKey:key];
    NSDictionary *rowDesc = [valuesSection objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {        
        cell = [[[UITableViewCell alloc ]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        //NSLog(@"ALLOCATA cella %p",cell);
    }
    else{
        //NSLog(@"RICICLO cella %p",cell);
    }
    
    if(indexPath.section == 0){
        cell.textLabel.text = @"Filtro";
        cell.accessoryView = aSwitch; 
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else{
        cell.textLabel.text = [rowDesc objectForKey:@"label"];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.accessoryView = nil;
    }
    
    //riassegna il checkmark alle celle che lo avevano
    if(selectedCells != nil && [selectedCells containsObject:[rowDesc objectForKey:@"enum"]]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{  
    return [sections objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    //NSLog(@"number row");
    NSString *key=[sections objectAtIndex:section];
    NSArray *values = [tableStructure  objectForKey:key];
    return [values count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //NSLog(@"number section");
    return sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    //TODO: SISTEMARE
    
    switch (section) {
        case 0:
            if(aSwitch.on)
                return @"Disattivando il filtro ti verranno mostrati i lavori appartenenti a qualsiasi settore";
            else return @"Attivando il filtro ti verranno mostrati solo i lavori appartenenti ai settori da te scelti";
            break;
        case 1:
            return nil;
            break;
            
        default:
            return nil;
            break;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   
    //reperisco informazioni su una determinata cella
    NSString *key = [sections objectAtIndex:indexPath.section];
    NSArray *valuesSection = [tableStructure objectForKey:key];
    NSDictionary *rowDesc = [valuesSection objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    //assegno o tolgo il checkmark alle celle selezionate
    if(indexPath.section != 0){    
        if(cell.accessoryType != UITableViewCellAccessoryCheckmark){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [selectedCells addObject:[rowDesc objectForKey:@"enum"]];
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryNone;
            [selectedCells removeObject:[rowDesc objectForKey:@"enum"]];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
}

// metodi per gestire la barra degli indici nella view
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if(aSwitch.on)
        return  indeces;
    else return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if(aSwitch.on)
        return [sections indexOfObject:title];
    return 0;
}

-(void)switchChanged
{   
    //imposto il range per le nuove sezioni da inserire nella tableView
    NSRange range;
    range.location = 1;
    
    if(aSwitch.on){
        //NSLog(@"SWITCH ON");
        
        //cambio il model aggiungendogli le informazioni sulle nuove sezioni e celle da aggiungere
        for(int i = 1; i < structureFromPlist.count;i++){
            NSDictionary *tempDict = [structureFromPlist objectAtIndex:i];             
            [self.tableStructure addEntriesFromDictionary:tempDict];
        }
        
        NSArray *tempArray = [[tableStructure allKeys] sortedArrayUsingSelector:@selector(compare:)];

        //aggiungo  all'array che contiene i nomi delle sezioni le nuove sezioni
        [self.sections addObjectsFromArray:tempArray];

        //rimuovo ultimo elemento che è la ripetizione del nome della prima sezione
        [self.sections removeObjectAtIndex: 0];

        //setto la lunghezza massima del range in base lunghezza effettiva array sections
        range.length = sections.count - 1;
  
        [self.tableView beginUpdates];
        
        [self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:range] withRowAnimation:UITableViewRowAnimationBottom];
        [self.tableView endUpdates];  
        [self.tableView reloadData];
    }
    else{
        range.length = sections.count - 1;
        
        //elimino dal model tutte le sezioni tranne la prima e rifaccio l'update
        
        [self.tableStructure removeObjectsForKeys:[sections objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]]];
        
        //rimuovo tutte le sezioni tranne la prima
        [self.sections removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
        
        //rimuovo tutti i checkmarks dalle celle quando faccio switch off
        [selectedCells removeAllObjects];
    
        [self.tableView beginUpdates];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:range] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates]; 
        [self.tableView reloadData];
    }
}

#pragma mark - View lifecycle

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    //quando la view sarà dismessa salva la struttura della tabella e le info sulle celle selezionate
    [prefs removeObjectForKey:@"tableStructure"];
    [prefs removeObjectForKey:@"sections"];
    [prefs setObject:tableStructure forKey:@"tableStructure"];
    [prefs setObject:sections forKey:@"sections"];
    [prefs removeObjectForKey:@"switch"];
    [prefs setBool:aSwitch.on forKey:@"switch"];
    [prefs removeObjectForKey:@"selectedCells"];
    [prefs setObject:selectedCells forKey:@"selectedCells"];
    
    //salvo informazioni sullo stato del filtro, se attivato o no
    [prefs removeObjectForKey:@"switchStatus"];
    if(aSwitch.on)
        [prefs setObject:@"ON" forKey:@"switchStatus"];
    else [prefs setObject:@"OFF" forKey:@"switchStatus"];
    [prefs synchronize];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"did load");
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    //recupero path del file plist
    NSString *plisStructure = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    //recupero array
    self.structureFromPlist = [NSArray arrayWithContentsOfFile:plisStructure];
    
    //chiamato al PRIMO avvio dell'app quando si fa tap sul tasto "filtro"
    if([prefs objectForKey:@"tableStructure"] == nil){
        
        //NSLog(@"prefs = nil");

        //struttura della tabella composta da una sola sezione e una sola cella (il primo dizionario)
        self.tableStructure = [[[NSMutableDictionary alloc] initWithDictionary:[structureFromPlist objectAtIndex:0]]autorelease]; 
        
        //creao array di settori indicizzati e in ordine alfabetico (0=A,1=B,...)
        NSArray *tempArray = [[tableStructure allKeys] sortedArrayUsingSelector:@selector(compare:)];
        self.sections  = [[[NSMutableArray alloc] initWithArray:tempArray] autorelease];
                
        self.selectedCells = [[[NSMutableArray alloc]init] autorelease];       
    }
    else{
        /*chimato ogni volta che esiste salvata in memoria una struttura della tabella lasciata ad un passaggio precedente da questa vista*/
        //NSLog(@"prefs != nil");
        self.tableStructure = [[[prefs objectForKey:@"tableStructure"] mutableCopy] autorelease];
//        NSLog(@"%@",tableStructure);
        self.sections = [[[prefs objectForKey:@"sections"] mutableCopy] autorelease];
        aSwitch.on = [prefs boolForKey:@"switch"];
        
        self.selectedCells = [[[prefs objectForKey:@"selectedCells"]mutableCopy]autorelease];
    }
    
    self.indeces = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",
                    @"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];

    self.title = @"Imposta filtro";//[[structureFromPlist objectAtIndex:0] objectForKey:@"name"];
}

- (void)viewDidUnload
{
    self.selectedCells = nil;
    self.sections = nil;
    self.structureFromPlist = nil;
    self.tableStructure = nil;
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
    [selectedCells release];
    [structureFromPlist release];
    [aSwitch release];
    [tableStructure release];
    [sections release];
    [super dealloc];
    
}
@end


