//
//  PickerViewController.m
//  jobFinder
//
//  Created by mario greco on 05/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PickerViewController.h"

@implementation PickerViewController
@synthesize picker, jobCategory;



//- (CGRect)pickerFrameWithSize:(CGSize)size
//{
//    CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
//    CGRect pickerRect = CGRectMake( 0.0,
//                                   screenRect.size.height - 84.0 - size.height,
//                                   size.width,
//                                   size.height);
//    return pickerRect;
//}



#pragma mark - PickerDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row
			forComponent:(NSInteger)component
{
	return [jobListCategory objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    //NSLog(@"selezionato dal picker: %@", [jobListCategory objectAtIndex:row]);
    
    jobCategory = [jobListCategory objectAtIndex:row]; /*[NSString stringWithFormat:@"%@",[jobListCategory objectAtIndex:row]];*/
    
    
//    NSLog(@"jobCategori stringa: %@",jobCategory);
 //   NSLog(@"puntatore stringa %p",jobCategory);
}

#pragma mark - PickerDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return jobListCategory.count;
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
    
//    
//    job = [[NSArray alloc] initWithObjects:
//                         @"Australia (AUD)", @"China (CNY)", @"France (EUR)",
//                         @"Great Britain (GBP)", @"Japan (JPY)", nil];
//    
//    self.exchangeRates = [[NSArray alloc] 
//                          initWithObjects: [NSNumber numberWithFloat:0.9922],
//                          [NSNumber numberWithFloat:6.5938], 
//                          [NSNumber numberWithFloat:0.7270],
//                          [NSNumber numberWithFloat:0.6206], 
//                          [NSNumber numberWithFloat:81.57], nil];
//    

    
    jobListCategory = [[NSArray alloc] initWithObjects:@"Ingegneria",@"Edilizia",@"Architettura",@"Medicina",@"Biologia",@"Chimica",@"Informatica",@"Idraulica", nil];
    
    jobCategory = [jobListCategory objectAtIndex:0];
    //NSLog(@"jobCategory iniziale= %@", jobCategory);
    
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

#pragma mark - memory management

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

-(void) dealloc
{
    [super dealloc];
    [picker release]; //??????
    //
    [jobListCategory release];

}

@end