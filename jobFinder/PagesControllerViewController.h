//
//  PagesControllerViewController.h
//  jobFinder
//
//  Created by mario greco on 28/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PagesControllerViewController : UIViewController {
	
	IBOutlet UILabel *etichettaNumeroPagina;
	int numeroPagina;
	
}


@property (nonatomic, retain) UILabel *etichettaNumeroPagina;

- (id)initWithnumeroPagina:(int)page;


@end
