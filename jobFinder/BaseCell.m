//
//  BaseCell.m
//  jobFinder
//
//  Created by mario greco on 18/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BaseCell.h"

@implementation BaseCell
@synthesize dataKey;

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withDictionary:(NSDictionary *)dictionary
{
    UITableViewCellStyle s = [[dictionary objectForKey:@"style"] integerValue];
    
    if (self = [super initWithStyle:s reuseIdentifier:reuseIdentifier]) {
		// Custom initialization    
        self.dataKey = [dictionary objectForKey:@"DataKey"];
        [self setImg:[dictionary objectForKey:@"img"]];
        self.textLabel.text = [dictionary objectForKey:@"label"];	
    }
    return self;
   
}





-(void) setDelegate:(id)delegate
{
}

-(void) setImg:(id)image{
}


//-(void) setPlaceHolder:(NSString *)placeholder{
//    
//}

-(void) setKeyboardType:(UIKeyboardType) keyboardType{
    
}



#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

#pragma  mark - Memory Management
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
@end
