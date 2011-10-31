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
@synthesize selectedCell,secDelegate, tableStructure, sections;

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
    // Return the number of sections.
//    NSLog(@"sections in sec = %d",sections.count);
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
        NSLog(@"CELLA RICICLATA");
        //cell.textLabel.text = [rowDesc objectForKey:@"label"];
    }    
    
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    
    //cell.detailTextLabel.text = @"CAZOOOOoooooooo ooooo oooooo ooooooo oooooo ooo";
    
    return cell;

}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{  
    return [sections objectAtIndex:section];
}

#warning pulire if-if
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
//    if(firsTime){
//        indexPathSelected = indexPath;
//        firsTime = FALSE;
//        [tableView cellForRowAtIndexPath:indexPath].accessoryType = 
//            UITableViewCellAccessoryCheckmark;
//        [selectedCells replaceObjectAtIndex:indexPath.row 
//                                 withObject:@"selected"];
//        }
//    
//    if(indexPath.row != indexPathSelected.row){
//        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
//        [selectedCells replaceObjectAtIndex:indexPath.row 
//                                 withObject:@"selected"];
//        [tableView cellForRowAtIndexPath:indexPathSelected].accessoryType = UITableViewCellAccessoryNone;
//        [selectedCells replaceObjectAtIndex:indexPathSelected.row 
//                                 withObject:@"noSelected"];
//       // [selectedCells insertObject:@"notSelected" atIndex:indexPath.row];
//        indexPathSelected = indexPath;
//    }
//    
//    selectedCell = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
//    [secDelegate receiveSectorFromTable:selectedCell];   
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"employeeDidSet" object:self userInfo:nil]; 
//    
//    [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Settori";
    
    NSString *plisStructure = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    self.tableStructure = [NSDictionary dictionaryWithContentsOfFile:plisStructure];
    self.sections = [[tableStructure allKeys] sortedArrayUsingSelector:@selector(compare:)];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Memory Managament

-(void) dealloc
{
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
