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
    // Return the number of rows in the section.
    //	if([sections count] == 0)
    //		return 0;
    
    //    if(section == 0 && !aSwitch.on)
    //        return 1;
    
    return [[rowInSection objectAtIndex:section] intValue];
    
    //    NSString *key=[sections objectAtIndex:section];
    //    NSArray *values = [tableStructure  objectForKey:key];
    //    return [values count];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    //    NSLog(@"sections in sec = %d",sections.count);
    if(!aSwitch.on)
        return 1;
    //return sections.count > 0 ? sections.count : 0;
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
    //[self reloadInputViews];
    //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];    
    [self.tableView reloadData];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //    aSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    //    [aSwitch addTarget:self action:@selector(switchChanged) forControlEvents:UIControlEventValueChanged];
    //    aSwitch.on = NO;
    
    //recupero path del file plist
    NSString *plisStructure = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    //recupero array
    self.structureFromPlist = [NSArray arrayWithContentsOfFile:plisStructure];
    
    //struttura della tabella, ovvero il dizionario con i settori di lavoro
    self.tableStructure = [structureFromPlist objectAtIndex:1]; 
    
    //creao array di settori indicizzati e in ordine alfabetico (0=A,1=B,...)
    NSArray *tempArray = [[tableStructure allKeys] sortedArrayUsingSelector:@selector(compare:)];
    self.sections  = [[NSMutableArray alloc] initWithArray:tempArray];
    //aggiungo sezione in indice zero senza nome, serve per la cella switch
    [self.sections insertObject: [[self.structureFromPlist objectAtIndex:2] objectForKey:@"switch"] atIndex:0];
    
    
    
    rowInSection = [[NSMutableArray alloc]init];
    [rowInSection insertObject: [NSNumber numberWithInt:1] atIndex:0];
    
    [rowInSection insertObject: [NSNumber numberWithInt:[[tableStructure objectForKey:@"A"] count]] atIndex:1];  
    [rowInSection insertObject: [NSNumber numberWithInt:[[tableStructure objectForKey:@"B"] count]] atIndex:2];  
    [rowInSection insertObject: [NSNumber numberWithInt:[[tableStructure objectForKey:@"C"] count]] atIndex:3];  
    //    NSLog(@"ARRAY ROWINSECTION: %d", [[rowInSection objectAtIndex:0] intValue]);
    //    NSLog(@"ARRAY ROWINSECTION: %d", [[rowInSection objectAtIndex:1] intValue]);
    //    NSLog(@"ARRAY ROWINSECTION: %d", [[rowInSection objectAtIndex:2] intValue]);
    //    NSLog(@"ARRAY ROWINSECTION: %d", [[rowInSection objectAtIndex:3] intValue]);    
    
    
    
    
    
    self.title = @"Imposta filtro";//[[structureFromPlist objectAtIndex:0] objectForKey:@"name"];
    
    
    
    
    //NSLog(@"TABLE STRUCTURE %@",tableStructure);
    
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


