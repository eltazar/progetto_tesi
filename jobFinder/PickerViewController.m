//
//  PickerViewController.m
//  jobFinder
//
//  Created by mario greco on 05/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PickerViewController.h"

@implementation PickerViewController
@synthesize picker;



//- (CGRect)pickerFrameWithSize:(CGSize)size
//{
//    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
//    CGRect pickerRect = CGRectMake( 0.0,
//                                   screenRect.size.height - 84.0 - size.height,
//                                   size.width,
//                                   size.height);
//    return pickerRect;
//}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (NSString *)pickerView:(UIPickerView *)pickerView
			 titleForRow:(NSInteger)row
			forComponent:(NSInteger)component
{
	return [NSString stringWithFormat:@"VALORE NUM:%d",row];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return 20;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{   
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //picker = [[UIPickerView alloc] initWithFrame:CGRectZero];
    //CGSize pickerSize = [picker sizeThatFits:CGSizeZero];
    //picker.frame = [self pickerFrameWithSize:pickerSize];
    
    picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 20, 320, 216)];
    [self.view setFrame:CGRectMake(0, 20, 320, 216)];
    
   // picker.autoresizingMask = UIViewAutoresizingNone;
    picker.showsSelectionIndicator = YES;       // note this is default to NO
    
    // this view controller is the data source and delegate
    picker.delegate = self;
    picker.dataSource = self;
//    self.view = picker;
    [self.view addSubview:picker];
    
    //    [self.view setBounds:CGRectMake(0,100, 320, 216)];
    //    [self.view addSubview:positionPicker];
    

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    picker = nil; //????
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) dealloc
{
    [super dealloc];
    [picker release]; //??????

}

@end