//
//  SectorTableViewController.m
//  jobFinder
//
//  Created by mario greco on 12/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SectorTableViewController.h"


@implementation SectorTableViewController
@synthesize selectedCell,secDelegate;

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:@"RootJobViewController" bundle:nil];
    if(self){
        selectedCells = [[NSMutableArray alloc] init];
        
    }
    return self;
}

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        [cell setAccessoryView:nil];
    }
    else{

        //NSLog(@"dentro riuso row: %d",indexPath.row);
        
        if([[selectedCells objectAtIndex:indexPath.row] isEqualToString:@"selected"]){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            NSLog(@"mark:INDEX PATH. ROW = %d",indexPath.row);
        }    
        else{            
            cell.accessoryType = UITableViewCellAccessoryNone;
            //NSLog(@"nomark:INDEX PATH. ROW = %d",indexPath.row);
        }
    }
    
    cell.textLabel.text = [list objectAtIndex:indexPath.row];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#warning pulire if-if
#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    if(firsTime){
        indexPathSelected = indexPath;
        firsTime = FALSE;
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = 
            UITableViewCellAccessoryCheckmark;
        [selectedCells replaceObjectAtIndex:indexPath.row 
                                 withObject:@"selected"];
        }
    
    if(indexPath.row != indexPathSelected.row){
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
        [selectedCells replaceObjectAtIndex:indexPath.row 
                                 withObject:@"selected"];
        [tableView cellForRowAtIndexPath:indexPathSelected].accessoryType = UITableViewCellAccessoryNone;
        [selectedCells replaceObjectAtIndex:indexPathSelected.row 
                                 withObject:@"noSelected"];
       // [selectedCells insertObject:@"notSelected" atIndex:indexPath.row];
        indexPathSelected = indexPath;
    }
    
    selectedCell = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    [secDelegate receiveSectorFromTable:selectedCell];   
    [[NSNotificationCenter defaultCenter] postNotificationName:@"employeeDidSet" object:self userInfo:nil]; 
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Settori";
        
    firsTime = TRUE;    
    //elementi da visualizzare nella tabella
	list = [[NSMutableArray alloc] initWithObjects:@"Settore 1", @"Settore 2",
            @"Settore 3", @"Settore 4", @"Settore 5", @"Settore 6", @"Settore 7", @"Settore 8", @"Settore 9", @"Settore 10", nil];
    //NSLog(@"list grande = %d",list.count);
    
    for(int i=0;i<list.count;i++)
        [selectedCells addObject:@"noSelected"];
    //NSLog(@"array grande = %d",selectedCells.count);        
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) dealloc
{
    [super dealloc];
    [selectedCells release];
    [list release];
}



@end
