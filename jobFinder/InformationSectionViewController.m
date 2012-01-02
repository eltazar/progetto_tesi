//
//  InformationSectionViewController.m
//  jobFinder
//
//  Created by mario greco on 31/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "InformationSectionViewController.h"
#import "ConfigViewController.h"
#import "CreditsViewController.h"
#import "HelpViewController.h"
#import "BaseCell.h"
#import "TextAreaCell.h"

@implementation InformationSectionViewController
@synthesize delegate;



- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}






#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{  
    return [sectionDescripition objectAtIndex:section];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return sectionDescripition.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section
{   
    if(sectionData){
        return [[sectionData objectAtIndex: section] count];
    } 
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sec = [sectionData objectAtIndex:indexPath.section];
    NSDictionary *rowDesc = [sec objectAtIndex:indexPath.row]; 
    NSString *dataKey = [rowDesc objectForKey:@"DataKey"];
    NSString *kind = [rowDesc objectForKey:@"kind"];
    int cellStyle = UITableViewCellStyleDefault;
    
    BaseCell *cell = (BaseCell *)[tableView dequeueReusableCellWithIdentifier: dataKey];
    
    //se non è recuperata creo una nuova cella
	if (cell == nil) {
        cell = [[[NSClassFromString(kind) alloc] initWithStyle: cellStyle reuseIdentifier:kind withDictionary:rowDesc] autorelease];
    }
    
    if([[rowDesc objectForKey:@"kind"] isEqualToString:@"TextAreaCell"]){
        //rendo la cella non editabile
        ((TextAreaCell *)cell).textView.editable = NO;
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = indexPath.section;
    int row = indexPath.row;
    
    if(section == 0){
        if(row == 0){
                ConfigViewController *configView = [[ConfigViewController alloc] initWithNibName:@"ConfigViewController" bundle:nil];
                [configView setDelegate:self];
            
            [UIView 
             transitionWithView:self.navigationController.view
             duration:0.8
             options:UIViewAnimationOptionTransitionFlipFromRight
             animations:^{ 
                 [self.navigationController 
                  pushViewController: configView 
                  animated:NO];
             }
             completion:NULL]; 
            
            [configView release];
        }
        else if(row == 1){
            HelpViewController *helpView = [[HelpViewController alloc] init];
            [self.navigationController pushViewController:helpView animated:YES];
            [helpView release];
        }
        else if(row == 2){
            CreditsViewController *creditsView = [[CreditsViewController alloc]initWithNibName:@"CreditsViewController" bundle:nil];
            [self.navigationController pushViewController:creditsView animated:YES];
            [creditsView release];
        }
    }
    
    //deseleziona la cella
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; 

}

#pragma mark - ConfigViewControllerDelegate
-(void)didSelectedFavouriteZone:(CLLocationCoordinate2D)coordinate
{
    if(delegate && [delegate respondsToSelector:@selector(didSelectedFavouriteZone:)])
        [delegate didSelectedFavouriteZone:coordinate]; 

}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //setta titolo vista
    [self setTitle:@"Generali"];
    //self.navigationItem.hidesBackButton = TRUE;
    
    
    
    //creo le sezioni
    NSMutableArray *secA = [[NSMutableArray alloc] init];
    NSMutableArray *secB = [[NSMutableArray alloc] init];
    
    [secA insertObject:[[[NSMutableDictionary alloc] initWithObjectsAndKeys:
                         @"config",                @"DataKey",
                         @"ActionCell",               @"kind",
                         @"Impostazioni",           @"label",
                         @"",                       @"detailLabel",
                         @"",               @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleDefault], @"style",
                         nil] autorelease] atIndex: 0];
    
    [secA insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"help",           @"DataKey",
                         @"ActionCell",       @"kind",
                         @"Help",       @"label",
                         @"",       @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleDefault], @"style",
                         nil] autorelease] atIndex: 1];
    
    [secA insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"credits",            @"DataKey",
                         @"ActionCell",         @"kind",
                         @"Credits",            @"label",
                         @"",                   @"img",
                         [NSString stringWithFormat:@"%d", UITableViewCellStyleDefault], @"style",
                         nil] autorelease] atIndex: 2];
    
    [secB insertObject:[[[NSDictionary alloc] initWithObjectsAndKeys:
                         @"disclaimer",              @"DataKey",
                         @"TextAreaCell",      @"kind",
                         @"",                  @"label",
                         @"",                  @"img",
                         nil]autorelease] atIndex: 0];
    
    
    
    
    
    sectionData = [[NSArray alloc] initWithObjects: secA, secB, nil];
    sectionDescripition = [[NSArray alloc] initWithObjects:@"", @"Disclaimer",nil];
    
    [secA autorelease];
    [secB autorelease];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [sectionDescripition release];
    sectionDescripition = nil;
    [sectionData release];
    sectionData = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma mark - MemoryManagement

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


-(void)dealloc{
    [sectionData release];
    [sectionDescripition release];
    [super dealloc];
}

@end
