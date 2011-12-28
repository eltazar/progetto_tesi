//
//  HelpViewController.m
//  jobFinder
//
//  Created by mario greco on 28/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HelpViewController.h"

@implementation HelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(IBAction)changeView:(id)sender{
    NSLog(@"CURRENT PAGE %d ", [pageCtrl currentPage]);
    switch ([pageCtrl currentPage]) {
        case 0:
            [view2 removeFromSuperview];
            [view3 removeFromSuperview];
            [self.view addSubview:view1];
            break;
            
        case 1:
            [view1 removeFromSuperview];
            [view3 removeFromSuperview];
            [self.view addSubview:view2];
            break;
            
        case 2:
            [view1 removeFromSuperview];
            [view2 removeFromSuperview];
            [self.view addSubview:view3];
            break;
            
        default:
            break;
    }
    
}

-(void)oneFingerSwipeLeft:(id)sender{
    
    NSLog(@"SWIPE LEFT");
    
    switch ([pageCtrl currentPage]) {
        case 0:
            [view1 removeFromSuperview];
            [view3 removeFromSuperview];
            [self.view addSubview:view2];
            [pageCtrl setCurrentPage:1];
            break;
            
        case 1:
            [view1 removeFromSuperview];
            [view2 removeFromSuperview];
            [self.view addSubview:view3];
            [pageCtrl setCurrentPage:2];
            break;
            
        default:
            break;
    }


    
}

-(void)oneFingerSwipeRight:(id)sender{
    
    NSLog(@"SWIPE RIGTH");
    switch ([pageCtrl currentPage]) {
            
        case 1:
            [view2 removeFromSuperview];
            [view3 removeFromSuperview];
            [self.view addSubview:view1];
            [pageCtrl setCurrentPage:0];
            break;
            
        case 2:
            [view1 removeFromSuperview];
            [view3 removeFromSuperview];
            [self.view addSubview:view2];
            [pageCtrl setCurrentPage:1];
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTitle:@"Help"];
    
    NSLog(@"DID LOAD CURRENT PAGE = %d",[pageCtrl currentPage]);
    //[pageCtrl setCurrentPage:0];
    
   //un dito swipe verso sinistra
    UISwipeGestureRecognizer *oneFingerSwipeUp = 
    [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerSwipeLeft:)] autorelease];
    [oneFingerSwipeUp setDirection:UISwipeGestureRecognizerDirectionLeft];
    [[self view] addGestureRecognizer:oneFingerSwipeUp];
    
   //un dito swipe verso destra
    UISwipeGestureRecognizer *oneFingerSwipeDown = 
    [[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerSwipeRight:)] autorelease];
    [oneFingerSwipeDown setDirection:UISwipeGestureRecognizerDirectionRight];
    [[self view] addGestureRecognizer:oneFingerSwipeDown];


    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    NSLog(@"HELP VIEW DID UNLOAD");
    
    [pageCtrl release];
    pageCtrl = nil;
    [view1 release];
    view1 = nil;
    [view2 release];
    view2 = nil;
    [view3 release];
    view3 = nil;

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dealloc{
    
    [pageCtrl release];
    [view1 release];
    [view2 release];
    [view3 release];

    [super dealloc];
}


@end
