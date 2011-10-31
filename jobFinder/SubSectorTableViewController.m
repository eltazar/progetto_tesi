//
//  SubSectorTableViewController.m
//  jobFinder
//
//  Created by mario greco on 31/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SubSectorTableViewController.h"
#import "BaseCell.h"

@implementation SubSectorTableViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    BaseCell *cell = (BaseCell*)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    
    return cell; 
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    NSLog(@"Selezionata riga %d sezione %d",indexPath.row, indexPath.section);

    NSArray *array = [tableStructure objectForKey:[sections objectAtIndex:indexPath.section]];
    NSDictionary *choiceDic = [array objectAtIndex:indexPath.row];
    NSString *choice = [choiceDic objectForKey:@"label"];
    //NSLog(@"PROVA LABEL: %@", choice);
    [super.secDelegate receiveSectorFromTable:choice];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    NSLog(@"DELEGATO è: %p",secDelegate);
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - Memory Management

-(void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


@end
