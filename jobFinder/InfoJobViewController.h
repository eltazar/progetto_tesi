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
#import <MessageUI/MessageUI.h>


@interface InfoJobViewController : RootJobViewController <MFMailComposeViewControllerDelegate>
{ 
}

-(id) initWithJob:(Job *)aJob;
-(void) fillCell:(UITableViewCell*)cell InRow:(int)row inSection:(int)section;

//@property(nonatomic,retain) Job *job;
-(void) setJob:(Job*) newJob;
@end

