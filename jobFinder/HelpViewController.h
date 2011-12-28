//
//  HelpViewController.h
//  jobFinder
//
//  Created by mario greco on 28/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpViewController : UIViewController{

    IBOutlet UIPageControl *pageCtrl;
    IBOutlet UIView *view1;
    IBOutlet UIView *view2;
    IBOutlet UIView *view3;
    
}


-(IBAction) changeView:(id)sender;
-(void)oneFingerSwipeLeft:(id)sender;
-(void)oneFingerSwipeRight:(id)sender;
@end
