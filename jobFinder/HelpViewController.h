//
//  HelpViewController.h
//  jobFinder
//
//  Created by mario greco on 28/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpViewController : UIViewController<UIScrollViewDelegate>{

	IBOutlet UIScrollView *scrollView;
	IBOutlet UIPageControl *pageControl;
	NSMutableArray *arrayDelleView;
	BOOL pageControlUsato;
	
}

@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) UIPageControl *pageControl;
@property (nonatomic, retain) NSMutableArray *arrayDelleView;

- (IBAction)cambiaPagina:(id)sender;
- (void)loadScrollViewWithPage:(int)page;
- (void)scrollViewDidScroll:(UIScrollView *)sender;
@end
