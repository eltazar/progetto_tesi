//
//  InfoJobViewController.h
//  jobFinder
//
//  Created by mario greco on 03/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootJobViewController.h"
#import "TextAreaCell.h"
#import "ActionCell.h"

@interface InfoJobViewController : RootJobViewController


-(void) fillCell:(UITableViewCell*)cell InRow:(int)row inSection:(int)section;

@end

