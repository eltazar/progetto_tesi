//
//  FilterViewController.m
//  jobFinder
//
//  Created by mario greco on 30/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FilterViewController.h"

@implementation FilterViewController
@synthesize tableStructure, sections, structureFromPlist;

-(id) initWithPlist:(NSString *)plist
{
    self = [super initWithNibName:@"RootJobViewController" bundle:nil];
    if(self){
        plistName = plist;
    }
    return self;
    
}

#pragma mark - DataSourceDelegate


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
    static NSString *CellIdentifier = @"cell";
    
    
    NSString *key = [sections objectAtIndex:indexPath.section];
    NSArray *valuesSection = [tableStructure objectForKey:key];
    NSDictionary *rowDesc = [valuesSection objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {        
        cell = [[[UITableViewCell alloc ]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [rowDesc objectForKey:@"label"];
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    
    return cell;
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{  
    return [sections objectAtIndex:section];
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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *plisStructure = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    self.structureFromPlist = [NSArray arrayWithContentsOfFile:plisStructure];
    
    self.title = [[structureFromPlist objectAtIndex:0] objectForKey:@"name"];
    
    self.tableStructure = [structureFromPlist objectAtIndex:1];
    self.sections = [[tableStructure allKeys] sortedArrayUsingSelector:@selector(compare:)];
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
    [tableStructure release];
    [sections release];
    [super dealloc];

}



@end

