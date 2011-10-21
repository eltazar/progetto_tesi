//
//  EditJobViewController.h
//  jobFinder
//
//  Created by mario greco on 03/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootJobViewController.h"
#import "SectorTableViewController.h"

@interface EditJobViewController : RootJobViewController <UITextFieldDelegate, UITextViewDelegate, SectorTableDelegate>{

    NSArray *fields;
    
}
@property(nonatomic,retain,readonly) NSArray *fields;

-(void)fillCell: (UITableViewCell *)cell rowDesc:(NSDictionary *)rowDesc;

@end
