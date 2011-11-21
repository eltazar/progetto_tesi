//
//  RootJobViewController.m
//  jobFinder
//
//  Created by mario greco on 03/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootJobViewController.h"
//#import "ActionCell.h"
#import "BaseCell.h"

@implementation RootJobViewController
@synthesize job; 


#pragma mark - init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.job = nil; //commentato 19 novembre
    }
    return self;
}

#pragma mark - DataSourceDelegate


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return sectionDescripition.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger) section
{   
    if(sectionData){
        //         NSLog(@"[AbstractJobViewController numOfRows]: %d", cellDescription.count);
        return [[sectionData objectAtIndex: section] count];    } 
    //    NSLog(@"[AbstractJobViewController numOfRows]: %d", 0);
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *sec = [sectionData objectAtIndex:indexPath.section];
    NSDictionary *rowDesc = [sec objectAtIndex:indexPath.row]; 
    NSString *kind = [rowDesc objectForKey:@"kind"];
    NSString *dataKey = [rowDesc objectForKey:@"DataKey"];
    
    int cellStyle = UITableViewCellStyleDefault;
    
    BaseCell *cell = (BaseCell *)[tableView dequeueReusableCellWithIdentifier:dataKey];
        
    if (cell == nil) {       
        cell = [[[NSClassFromString(kind) alloc] initWithStyle: cellStyle reuseIdentifier:kind withDictionary:rowDesc] autorelease];
    }
    
    
    //di default imposto la cella come non selezionabile (non diventa blu)
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //imposto la label della cella
    //TODO: aggiungere immagine alla cella
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    return [sectionDescripition objectAtIndex:section];
}

#pragma mark - TableViewDelegate


//setto altezza celle
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{   
    [super viewDidLoad];
    
    
    //    UIBarButtonItem* btnSubmitSignup = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Join",@"") style:UIBarButtonItemStylePlain target:self action:@selector(bla:)];
    //	[[self navigationItem] setRightBarButtonItem:btnSubmitSignup];
    
    //    tableView = [[EditableJobViewController alloc] init]; 
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //    [self.centralView addSubview:tableView.view];    
    
    
    
    //    UITableViewController *prova = [[UITableViewController alloc] init ];
    //    //tableController = [[UITableViewController alloc] init];
    //    [self.view addSubview:prova.tableView];
    
    
    
    
    
    // Do any additional setup after loading the view from its nib.
    /*self.title = @"Dettagli";
     self.insertButton =[[UIBarButtonItem alloc]
     initWithTitle:@"Inserisci" style:(UIBarButtonSystemItemAdd) target:(self) action:@selector(bla)];
     self.navigationItem.rightBarButtonItem = insertButton ; // not it..
     //[self.navigationController presentModalViewController:self animated:YES];
     
     [insertButton release] ;*/
    
    
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


#pragma mark Texfield Delegate
//- (BOOL)textFieldShouldReturn:(UITextField *)textField
//{ 
//	[textField resignFirstResponder];
//	return YES;
//}

//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
//}


#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)dealloc
{
    [sectionDescripition release];
    [sectionData release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
