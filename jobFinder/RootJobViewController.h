//
//  RootJobViewController.h
//  jobFinder
//
//  Created by mario greco on 03/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootJobViewController : UITableViewController <UITableViewDataSource/*,UITextFieldDelegate*/>{
    @protected
    NSArray *sectionDescripition;
    NSArray *sectionData;
}

@end
