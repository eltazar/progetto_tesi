//
//  FilterViewController.m
//  jobFinder
//
//  Created by mario greco on 30/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterViewController.h"

//metodi privati
@interface FilterViewController()
-(void)switchChanged;
-(void)changeFrameTables;
-(void)fadeOut:(UIView*)viewToDissolve withDuration:(NSTimeInterval)duration andWait:(NSTimeInterval)wait;
-(void)fadeIn:(UIView*)viewToFadeIn withDuration:(NSTimeInterval)duration andWait:(NSTimeInterval)wait;
@end

@implementation FilterViewController
@synthesize tableStructureForSwitchTable, sectionsForSwitchTable, structureForSwitchTable, selectedCells, indeces, mainView, switchTable, contentTable,tableStructureForContentTable, sectionsForContentTable, structureForContentTable;

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    
    self = [super initWithNibName:@"FilterViewController" bundle:nil];
    
    if(self){
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
    
    
    if(tableView == contentTable){
       // NSLog(@"ENTRATO");
        
        static NSString *CellIdentifier = @"cell";
        NSString *key = [sectionsForContentTable objectAtIndex:indexPath.section];
        NSArray *valuesSection = [tableStructureForContentTable objectForKey:key];
        NSDictionary *rowDesc = [valuesSection objectAtIndex:indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        
        if (cell == nil) {        
            cell = [[[UITableViewCell alloc ]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            //NSLog(@"ALLOCATA cella %p",cell);
        }
        else{
            //NSLog(@"RICICLO cella %p",cell);
        }
        cell.textLabel.text = [rowDesc objectForKey:@"label"];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.numberOfLines = 2;
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        cell.accessoryView = nil;
        
        //riassegna il checkmark alle celle che lo avevano
        if(selectedCells != nil && [selectedCells containsObject:[rowDesc objectForKey:@"enum"]]){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;

    }
    else if(tableView == switchTable){
        
        static NSString *CellIdentifier = @"cell2";
        NSString *key = [sectionsForSwitchTable objectAtIndex:indexPath.section];
        NSArray *valuesSection = [tableStructureForSwitchTable objectForKey:key];
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
    else return nil;
    
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{  
    if(tableView == contentTable)
        return [sectionsForContentTable objectAtIndex:section];
    else if(tableView == switchTable){
        return [sectionsForSwitchTable objectAtIndex:section];
    }
    else return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{    
    //NSLog(@"number row");
    if(tableView == contentTable){
         //NSLog(@"ENTRATO 2");
        NSString *key=[sectionsForContentTable objectAtIndex:section];
        NSArray *values = [tableStructureForContentTable  objectForKey:key];
        return [values count];
    }
    else if(tableView == switchTable){
        NSString *key=[sectionsForSwitchTable objectAtIndex:section];
        NSArray *values = [tableStructureForSwitchTable objectForKey:key];
        return [values count];
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //NSLog(@"number section");
    if(tableView == contentTable){
        // NSLog(@"ENTRATO 3");
        return sectionsForContentTable.count;
    }
    else if(tableView == switchTable){
        return sectionsForSwitchTable.count;
    }
    else return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    
    //TODO: SISTEMARE
    if(tableView == switchTable){
        switch (section) {
            case 0:
                if(aSwitch.on)
                    return @"Disattivando il filtro ti verranno mostrati i lavori appartenenti a qualsiasi settore";
                else return @"Attivando il filtro ti verranno mostrati solo i lavori appartenenti ai settori da te scelti";
                break;
            default:
                return nil;
                break;
        }
    }
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   
    if(tableView == contentTable){
    
        //reperisco informazioni su una determinata cella
        NSString *key = [sectionsForContentTable objectAtIndex:indexPath.section];
        NSArray *valuesSection = [tableStructureForContentTable objectForKey:key];
        NSDictionary *rowDesc = [valuesSection objectAtIndex:indexPath.row];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        //assegno o tolgo il checkmark alle celle selezionate e salvo tale informazione
      
        if(cell.accessoryType != UITableViewCellAccessoryCheckmark){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [selectedCells addObject:[rowDesc objectForKey:@"enum"]];
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryNone;
            [selectedCells removeObject:[rowDesc objectForKey:@"enum"]];
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES]; 

    
    }
}


// metodi per gestire la barra degli indici nella view
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
   
    if(tableView == contentTable){
        // NSLog(@"ENTRATO 5");
        return  indeces;
    
    }
    else return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
    if(tableView == contentTable)
        if(aSwitch.on)
            return [sectionsForContentTable indexOfObject:title];
        return 0;
    
    return 0;
    
}

-(void)switchChanged
{   

    if(aSwitch.on){
        [self changeFrameTables];
        [self fadeIn : contentTable withDuration: 0.3 andWait : 0.2 ];
    }
    else{
        [self changeFrameTables];
        [self fadeOut :contentTable withDuration: 0.3 andWait : 0.2 ];
    }
    
    //ricarica il titolo della section
    [switchTable reloadData];
}



#pragma mark - View lifecycle


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs removeObjectForKey:@"selectedCells"];
    [prefs setObject:selectedCells forKey:@"selectedCells"];
    
    [prefs removeObjectForKey:@"switch"];
    if(selectedCells.count == 0)
        [prefs setBool:NO forKey:@"switch"];
    else [prefs setBool:aSwitch.on forKey:@"switch"];

    [prefs synchronize];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"did load");
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    //recupero path del file plist
    NSString *plistStructure1 = [[NSBundle mainBundle] pathForResource:@"filter-tableSingleSection" ofType:@"plist"];
    
    NSString *plistStructure2 = [[NSBundle mainBundle] pathForResource:@"filter-table" ofType:@"plist"];
    
    
    //recupero array di dizionari
    self.structureForContentTable = [NSArray arrayWithContentsOfFile:plistStructure2];
    self.structureForSwitchTable = [NSArray arrayWithContentsOfFile:plistStructure1];
    
    
    //costruisco dizionario contenente il model della tabella switchTable
    self.tableStructureForSwitchTable = [[[NSMutableDictionary alloc] init]autorelease]; 
    for(NSDictionary *dic in structureForSwitchTable){
        [self.tableStructureForSwitchTable addEntriesFromDictionary:dic];
    }   

   //costruisco dizionario contenente il model della tabella contentTable
    self.tableStructureForContentTable = [[[NSMutableDictionary alloc] init]autorelease]; 
    for(NSDictionary *dic in structureForContentTable){
        [self.tableStructureForContentTable addEntriesFromDictionary:dic];
    }
        
    //costruisco array contenente nomi sezioni della tabella switchTable
    NSArray *tempArray = [tableStructureForSwitchTable allKeys];
    self.sectionsForSwitchTable = [[[NSMutableArray alloc] initWithArray:tempArray] autorelease]; 
    
    //costruisco array contenente nomi sezioni della tabella contentTable
    NSArray *tempArray2 =[[tableStructureForContentTable allKeys] sortedArrayUsingSelector:@selector(compare:)];
    self.sectionsForContentTable = [[[NSMutableArray alloc] initWithArray:tempArray2] autorelease];    
    //così "altro" sarà ultima sezione
    [sectionsForContentTable removeObject:@"Altro"];
    [sectionsForContentTable addObject:@"Altro"];
    //NSLog(@"SECTIONS 2 = %@", sections2);
    
    //array contente informazioni su quali celle sono state selezionate
    self.selectedCells = [[[NSMutableArray alloc]init] autorelease];   
    
    //recuper informazioni sullo stato dello switch
    aSwitch.on = [prefs boolForKey:@"switch"];
    
    //imposto i frame e le caratteristiche delle tabelle
    if(aSwitch.on){
        [self changeFrameTables];
        contentTable.alpha = 1;
    }
    else{
        [self changeFrameTables];
        contentTable. alpha = 0;
    }

    if([prefs objectForKey:@"selectedCells"]  != nil)
        self.selectedCells = [[[prefs objectForKey:@"selectedCells"]mutableCopy]autorelease];
    
    //indici per la content view
    self.indeces = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",
                    @"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];

    self.title = @"Imposta filtro";//[[structureFromPlist objectAtIndex:0] objectForKey:@"name"];
}

-(void)changeFrameTables
{
    if(aSwitch.on){
        self.switchTable.frame = CGRectMake(mainView.frame.origin.x, mainView.frame.origin.y+self.navigationController.view.frame.origin.y+10,mainView.frame.size.width,mainView.frame.size.height - contentTable.frame.size.height);
        switchTable.scrollEnabled = NO;
    }
    else{
        self.switchTable.frame = CGRectMake(mainView.frame.origin.x, mainView.frame.origin.y+self.navigationController.view.frame.origin.y+10,mainView.frame.size.width,mainView.frame.size.height);
        switchTable.scrollEnabled = YES;
    }
    
}

-(void)fadeOut:(UIView*)viewToDissolve withDuration:(NSTimeInterval)duration andWait:(NSTimeInterval)wait
{
    [UIView beginAnimations: @"Fade Out" context:nil];
    
    // wait for time before begin
    [UIView setAnimationDelay:wait];
    
    // druation of animation
    [UIView setAnimationDuration:duration];
    viewToDissolve.alpha = 0.0;
    [UIView commitAnimations];
}

-(void)fadeIn:(UIView*)viewToFadeIn withDuration:(NSTimeInterval)duration andWait:(NSTimeInterval)wait
{
    [UIView beginAnimations: @"Fade In" context:nil];
    
    // wait for time before begin
    [UIView setAnimationDelay:wait];
    
    // druation of animation
    [UIView setAnimationDuration:duration];
    viewToFadeIn.alpha = 1;
    [UIView commitAnimations];
    
}

- (void)viewDidUnload
{
    self.sectionsForContentTable = nil;
    self.structureForContentTable = nil;
    self.tableStructureForContentTable = nil;
    self.indeces = nil;
    self.selectedCells = nil;
    self.sectionsForSwitchTable = nil;
    self.structureForSwitchTable = nil;
    self.tableStructureForSwitchTable = nil;
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
    [tableStructureForContentTable release];
    [sectionsForContentTable release];
    [structureForContentTable release];
    [indices release];
    [selectedCells release];
    [structureForSwitchTable release];
    [aSwitch release];
    [tableStructureForSwitchTable release];
    [sectionsForSwitchTable release];
    [super dealloc];
    
}
@end


