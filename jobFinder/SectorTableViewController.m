//
//  SectorTableViewController.m
//  jobFinder
//
//  Created by mario greco on 12/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SectorTableViewController.h"
#import "BaseCell.h"

@implementation SectorTableViewController
@synthesize secDelegate, tableStructure, sections,structureFromPlist, indices;

-(id) initWithPlist:(NSString *)plist
{
    self = [super initWithNibName:@"RootJobViewController" bundle:nil];
    if(self){
        plistName = plist;
    }
    return self;
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sections.count > 0 ? sections.count : 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
	if([sections count] == 0)
		return 0;
	NSString *key=[sections objectAtIndex:section];
	NSArray *values = [tableStructure objectForKey:key];
	return [values count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    
    NSString *key = [sections objectAtIndex:indexPath.section];
    NSArray *valuesSection = [tableStructure objectForKey:key];
    NSDictionary *rowDesc = [valuesSection objectAtIndex:indexPath.row];
    NSString *kind = [rowDesc objectForKey:@"kind"]; 
    
    BaseCell *cell =(BaseCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    
    if (cell == nil) {        
        cell = [[[NSClassFromString(kind) alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier withDictionary:rowDesc] autorelease];
    }
    else{
        //NSLog(@"CELLA RICICLATA");
        cell.textLabel.text = [rowDesc objectForKey:@"label"];
    }    
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        
    return cell;

}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{  
    return [sections objectAtIndex:section];
}

// metodi per gestire la barra degli indici nella view
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return  indices;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    
    return [sections indexOfObject:title];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    //NSLog(@"Selezionata riga %d sezione %d",indexPath.row, indexPath.section);
    
    NSArray *array = [tableStructure objectForKey:[sections objectAtIndex:indexPath.section]];
    NSDictionary *choiceDic = [array objectAtIndex:indexPath.row];
    NSString *choice = [choiceDic objectForKey:@"label"];
    [secDelegate didReceiveSectorFromTable:choice  andCode: [choiceDic objectForKey:@"code"]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"employeeDidSet" object:self userInfo:nil];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *plisStructure = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    self.structureFromPlist = [NSArray arrayWithContentsOfFile:plisStructure];
    
    self.title = [[structureFromPlist objectAtIndex:0] objectForKey:@"name"];
    
    self.tableStructure = [structureFromPlist objectAtIndex:1];
    
    NSArray *sectionsTemp = [[NSArray alloc] initWithArray:[[tableStructure allKeys] sortedArrayUsingSelector:@selector(compare:)]];
    
    self.sections = [NSMutableArray arrayWithArray:sectionsTemp];
    [self.sections removeObject:@"Altro"];
    [self.sections addObject:@"Altro"];
    
    self.indices = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",
                    @"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
    [sectionsTemp release];
}
- (void)viewDidUnload
{
    self.structureFromPlist = nil;
    self.tableStructure = nil;
    self.sections = nil;
    self.indices = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Memory Managament

-(void) dealloc
{
    [indices release];
    [structureFromPlist release];
    [tableStructure release];
    [sections release];
    [super dealloc];
//    [selectedCells release];
//    [list release];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

@end
