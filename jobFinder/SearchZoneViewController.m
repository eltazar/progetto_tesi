//
//  SearchZoneViewController.m
//  jobFinder
//
//  Created by mario greco on 19/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SearchZoneViewController.h"
#import "GeoDecoder.h"
#import <objc/runtime.h>
#import "CoreLocation/CLLocation.h"

@implementation SearchZoneViewController
@synthesize tableData, theSearchBar, theTableView, disableViewOverlay, delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar
    textDidChange:(NSString *)searchText {
    // We don't want to do anything until the user clicks 
    // the 'Search' button.
    // If you wanted to display results as the user types 
    // you would do that here.
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    // searchBarTextDidBeginEditing is called whenever 
    // focus is given to the UISearchBar
    // call our activate method so that we can do some 
    // additional things when the UISearchBar shows.
    [self searchBar:searchBar activate:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    // searchBarTextDidEndEditing is fired whenever the 
    // UISearchBar loses focus
    // We don't need to do anything here.
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    // Clear the search text
    // Deactivate the UISearchBar
    searchBar.text=@"";
    [self searchBar:searchBar activate:NO];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // Do the search and show the results in tableview
    // Deactivate the UISearchBar
	
    // You'll probably want to do this on another thread
    // SomeService is just a dummy class representing some 
    // api that you are using to do the search
    
    GeoDecoder *geoDec = [[GeoDecoder alloc] init];
    [geoDec setDelegate:self];
    
    [geoDec searchCoordinatesForAddress:searchBar.text];
    
    [self searchBar:searchBar activate:NO];
	
//    [self.tableData removeAllObjects];
//    [self.tableData addObjectsFromArray:results];
//    [self.theTableView reloadData];
    
}

// We call this when we want to activate/deactivate the UISearchBar
// Depending on active (YES/NO) we disable/enable selection and 
// scrolling on the UITableView
// Show/Hide the UISearchBar Cancel button
// Fade the screen In/Out with the disableViewOverlay and 
// simple Animations
- (void)searchBar:(UISearchBar *)searchBar activate:(BOOL) active{	
    self.theTableView.allowsSelection = !active;
    self.theTableView.scrollEnabled = !active;
    if (!active) {
        [disableViewOverlay removeFromSuperview];
        [searchBar resignFirstResponder];
    } else {
        self.disableViewOverlay.alpha = 0;
        [self.view addSubview:self.disableViewOverlay];
		
        [UIView beginAnimations:@"FadeIn" context:nil];
        [UIView setAnimationDuration:0.5];
        self.disableViewOverlay.alpha = 0.6;
        [UIView commitAnimations];
		
        // probably not needed if you have a details view since you 
        // will go there on selection
        NSIndexPath *selected = [self.theTableView 
                                 indexPathForSelectedRow];
        if (selected) {
            [self.theTableView deselectRowAtIndexPath:selected 
                                             animated:NO];
        }
    }
    [searchBar setShowsCancelButton:active animated:YES];
}

#pragma mark - TableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = indexPath.row;
    [delegate didSelectedPreferredAddress:[[tableData objectAtIndex:row] objectForKey:@"address"] withLatitude:[[[tableData objectAtIndex:row] objectForKey:@"lat"] doubleValue]  andLongitude:[[[tableData objectAtIndex:row] objectForKey:@"long"] doubleValue] ];
    
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SearchResult";
    UITableViewCell *cell = [tableView
                             dequeueReusableCellWithIdentifier:cellIdentifier];
	
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2
                                       reuseIdentifier:cellIdentifier] autorelease];
    }
	
    NSDictionary *data = [self.tableData objectAtIndex:indexPath.row];
   // cell.textLabel.text = data;
    
	//NSLog( @"Table cell text: %@", [[transactionHistory objectAtIndex:row] description] );
    
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = [data objectForKey:@"address"];
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;	
    
    return cell;
}

#pragma mark - GeoDecoderDelegate

-(void) didReceivedGeoDecoderData:(NSDictionary *)geoData
{
    //NSLog(@"DICTIONARY IS: %@",geoData);
    NSLog(@"CLASSE: %s", class_getName([[geoData objectForKey:@"results"] class]));
    
    NSArray *resultsArray = [geoData objectForKey:@"results"];
    NSMutableArray *addresses = [[[NSMutableArray alloc] initWithCapacity:resultsArray.count] autorelease];
    
    for(int i=0; i < resultsArray.count; i++){
        
        NSDictionary *result = [resultsArray objectAtIndex:i];
        NSString *addressString = [ result objectForKey:@"formatted_address"];
        NSLog(@"ADDRESS_STRING = %@",addressString);
        CLLocationDegrees latitude = [[[[result objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] doubleValue];
        CLLocationDegrees longitude = [[[[result objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] doubleValue];
        NSLog(@"LAT = %f LONG = %f",latitude,longitude);
        
        NSDictionary *entry = [[[NSDictionary alloc] initWithObjectsAndKeys:
                                addressString, @"address", 
                                [NSNumber numberWithDouble: latitude] , @"lat", 
                                [NSNumber numberWithDouble: longitude], @"long", nil] autorelease];
        [addresses addObject:entry];
    }
//    [addresses addObject:@"<html>ciao come stai <br> bene grazie ciao</html>"];
//    NSLog(@"ARRAY ADDRESSES: %@",addresses);
    
    [self.tableData removeAllObjects];
    [self.tableData addObjectsFromArray:addresses];
    [self.theTableView reloadData];

}

/*
 geometry =             {
 bounds =                 {
 northeast =                     {
 lat = "7.2945335";
 lng = "171.940155";
 };
 southwest =                     {
 lat = "6.955802900000001";
 lng = "171.5436189";
 };
 };
 location =                 {
 lat = "7.061012799999999";
 lng = "171.647344";
 };

 */


#pragma mark - View lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setTitle:@"Cerca Zona"];
    self.tableData =[[NSMutableArray alloc]init];
    self.disableViewOverlay = [[UIView alloc]
                               initWithFrame:CGRectMake(0.0f,86.0f,320.0f,416.0f)];
    self.disableViewOverlay.backgroundColor=[UIColor blackColor];
    self.disableViewOverlay.alpha = 0;
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [self.theSearchBar becomeFirstResponder];
    [super viewDidAppear:animated];
}



#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)dealloc {
    [super dealloc];
    [theTableView release], theTableView = nil;
    [theSearchBar release], theSearchBar = nil;
    [tableData release];
}

@end