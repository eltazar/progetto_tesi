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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if(cell.accessoryType != UITableViewCellAccessoryCheckmark){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [selectedCells addObject:indexPath];
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
        [selectedCells removeObject:indexPath];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
}

-(void)switchChanged
{   
    //imposto il range per le nuove sezioni da inserire nella tableView
    NSRange range;
    range.location = 1;
    
    if(aSwitch.on){
        //NSLog(@"SWITCH ON");
        
        //cambio il model aggiungendogli le informazioni sulle nuove sezioni e celle
        for(int i = 1; i < structureFromPlist.count;i++){
            NSDictionary *tempDict = [structureFromPlist objectAtIndex:i];   
            //NSLog(@"++++++ TEMP DICTIO %@",tempDict);
            
            [self.tableStructure addEntriesFromDictionary:tempDict];
        //    NSLog(@"Table structure content = %@",tableStructure);
        }
        
        NSArray *tempArray = [[tableStructure allKeys] sortedArrayUsingSelector:@selector(compare:)];
        //NSLog(@"***** TEMP ARRAY = %@",tempArray);
    //    NSLog(@"***** SECTIONS = %@",sections);
       
        //aggiungo  all'array che contiene i nomi delle sezioni le nuove sezioni
        [self.sections addObjectsFromArray:tempArray];
        //NSLog(@"***** TEMP ARRAY = %@",tempArray);
    //    NSLog(@"####### SECTIONS = %@",sections);
        //rimuovo ultimo elemento che è la ripetizione del nome della prima sezione
        [self.sections removeObjectAtIndex: sections.count - 1 ];
    //     NSLog(@"*@@@@@@ SECTIONS = %@",sections);                                                  

//        NSLog(@"*@@@@@@ Table structure content = %@",tableStructure);
       //NSLog(@"*@@@@@@ SECTIONS = %@",sections);

        range.length = sections.count - 1;
        
        [self.tableView beginUpdates];
        //[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:YES];
        [self.tableView insertSections:[NSIndexSet indexSetWithIndexesInRange:range] withRowAnimation:UITableViewRowAnimationBottom];
        //[self.tableView insertSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:YES];
        [self.tableView endUpdates];        
    }
    else{
        range.length = sections.count - 1;
        
        //elimino dal model tutte le sezioni tranne la prima e rifaccio l'update
        
        [self.tableStructure removeObjectsForKeys:[sections objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]]];
        //NSLog(@"TABLE STRUCTURE = %@",tableStructure);
        
        [self.sections removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
        //NSLog(@"SECTIONS = %@",sections);
        
        [self.tableView beginUpdates];
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndexesInRange:range] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    }
}

#pragma mark - View lifecycle

//-(void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//    
//    if([prefs objectForKey:@"tableStructure"] != nil){
//        self.tableStructure = [prefs objectForKey:@"tableStructure"];
//    }
//    NSLog(@"WILL APPEAR: %@",tableStructure);
//    //NSLog(@"VIEW WILL APP: %@",[prefs objectForKey:@"tableStructure"]);
//    
//}
//
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    //quando la view sarà dismessa salva la struttura della tabella
    [prefs removeObjectForKey:@"tableStructure"];
    [prefs removeObjectForKey:@"sections"];
    [prefs setObject:tableStructure forKey:@"tableStructure"];
    [prefs setObject:sections forKey:@"sections"];
    [prefs removeObjectForKey:@"switch"];
    [prefs setBool:aSwitch.on forKey:@"switch"];
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
    
    //chiamato al PRIMO avvio dell'app quando si spinge il tasto "filtro"
    if([prefs objectForKey:@"tableStructure"] == nil){
        
        //NSLog(@"prefs = nil");

        //struttura della tabella composta da una sola sezione e una sola cella (il primo dizionario)
        self.tableStructure = [[[NSMutableDictionary alloc] initWithDictionary:[structureFromPlist objectAtIndex:0]]autorelease]; 
        
        //creao array di settori indicizzati e in ordine alfabetico (0=A,1=B,...)
        NSArray *tempArray = [[tableStructure allKeys] sortedArrayUsingSelector:@selector(compare:)];
        self.sections  = [[[NSMutableArray alloc] initWithArray:tempArray] autorelease];
        
        //aSwitch.on = NO;
        
    }
    else{
        /*chimato ogni volta che esiste salvata in memoria una struttura della tabella lasciata ad un passaggio precedente da questa vista*/
        //NSLog(@"prefs != nil");
        self.tableStructure = [[[prefs objectForKey:@"tableStructure"] mutableCopy] autorelease];
        NSLog(@"%@",tableStructure);
        self.sections = [[[prefs objectForKey:@"sections"] mutableCopy] autorelease];
        aSwitch.on = [prefs boolForKey:@"switch"];
    }
    


//    NSLog(@"*****************************************************");
//    NSLog(@"Table structure TYPE = %@",[tableStructure class]);
//
//    NSLog(@"TABLE STRUCTURE = %@",tableStructure);
//    NSLog(@"SECTIONS = %@",sections);
//    NSLog(@"*****************************************************");

    //selectedCells = [[NSMutableArray alloc]init];
    
//    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//    [prefs setObject:self.tableStructure forKey:@"tableStructure"];
    
        
//    if([prefs objectForKey:@"tableStructure"] != nil){
//        self.tableStructure = [prefs objectForKey:@"tableStructure"];
//    }

   // NSLog(@"DID LOAD %@",tableStructure);
    
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
    [structureFromPlist release];
    [aSwitch release];
    [tableStructure release];
    [sections release];
    [super dealloc];
    
}
@end


