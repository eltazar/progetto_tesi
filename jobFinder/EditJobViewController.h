//
//  EditJobViewController.h
//  jobFinder
//
//  Created by mario greco on 03/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootJobViewController.h"
#import "SectorTableViewController.h"

/* Rappresenta la tabella da mostrare in fase di creazione di un job
 */

@interface EditJobViewController : RootJobViewController <UITextFieldDelegate, UITextViewDelegate, SectorTableDelegate>{
    UISegmentedControl *segmentedCtrl;
    
}

-(void)fillCell: (UITableViewCell *)cell rowDesc:(NSDictionary *)rowDesc;

@end
