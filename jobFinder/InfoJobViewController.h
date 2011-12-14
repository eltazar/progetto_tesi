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
#import "GeoDecoder.h"
#import "FBConnect.h"
#import "Facebook.h"
#import "jobFinderAppDelegate.h"
#import "InfoCell.h"

/* Rappresenta la tabella dei dati da mostrare quando viene selezionato un job sulla mappa
 */

@interface InfoJobViewController : RootJobViewController <MFMailComposeViewControllerDelegate, GeoDecoderDelegate, FBSessionDelegate, FBDialogDelegate, FBRequestDelegate>
{ 
    NSArray *permissions;
    //Facebook *facebook;
    UIBarButtonItem *logoutBtn;
    GeoDecoder *geoDec;
    jobFinderAppDelegate *appDelegate;
    BOOL waitingForFacebook;
    InfoCell *spinnerCell;
}

-(id) initWithJob:(Job *)aJob;
-(void) fillCell:(UITableViewCell*)cell InRow:(int)row inSection:(int)section;

//@property(nonatomic,retain) Job *job;
@end

