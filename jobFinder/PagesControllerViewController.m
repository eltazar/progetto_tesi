//
//  PagesControllerViewController.m
//  jobFinder
//
//  Created by mario greco on 28/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PagesControllerViewController.h"


static NSArray *__pageControlColorList = nil;

@implementation PagesControllerViewController


@synthesize etichettaNumeroPagina;


// Creates the color list the first time this method is invoked. Returns one color object from the list.

+ (UIImageView *)pageControlColorWithIndex:(NSUInteger)index {
    if (__pageControlColorList == nil) {
        
        UIImageView *imgView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"helpView1.png"]];
        [imgView1 setFrame:CGRectMake(0, 0, 320, 389)];
        UIImageView *imgView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"helpView2.png"]];
        [imgView2 setFrame:CGRectMake(0, 0, 320, 389)];
        
        UIImageView *imgView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"helpView3.png"]];
        [imgView3 setFrame:CGRectMake(0, 0, 320, 389)];
        
        UIImageView *imgView4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"helpView4.png"]];
        [imgView4 setFrame:CGRectMake(0, 0, 320, 389)];
        
        UIImageView *imgView5 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"helpView5.png"]];
        [imgView5 setFrame:CGRectMake(0, 0, 320, 389)];
       
        __pageControlColorList = [[NSArray alloc] initWithObjects:imgView1,imgView2,imgView3,imgView4, imgView5, nil];
        
       [imgView1 release];
       [imgView2 release];
       [imgView3 release];
       [imgView4 release];
       [imgView5 release];
        
    }
    
    return [__pageControlColorList objectAtIndex:index % [__pageControlColorList count]];
}




// metodo chiamato quando effettuo lo scroll che carica la view di IB e inizializza il numero pagina

- (id)initWithnumeroPagina:(int)page {
	if (self = [super initWithNibName:@"PagesControllerViewController" bundle:nil])    {
		numeroPagina = page;
    }
    return self;
}



// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization.
 }
 return self;
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

// Set the label and background color when the view has finished loading.

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// imposto l'etichetta del numero della pagina (c'è il + 1 perchè numeroPagina è riferito all'array che come so parte da 0)
	etichettaNumeroPagina.text = [NSString stringWithFormat:@"Page %d", numeroPagina + 1];
	
	// imposto che il backgroundcolor della view deve essere determinato dal metodo dei colori passandogli il numero di pagina 
	[self.view addSubview:[PagesControllerViewController pageControlColorWithIndex:numeroPagina]];
	// self.view.backgroundColor = [UIColor grayColor];
}


/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations.
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[etichettaNumeroPagina release];
    [super dealloc];
}


@end
