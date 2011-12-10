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
/* Rappresenta la tabella dei dati da mostrare quando viene selezionato un job sulla mappa
 */

@interface InfoJobViewController : RootJobViewController <MFMailComposeViewControllerDelegate, GeoDecoderDelegate, FBSessionDelegate, FBDialogDelegate, FBRequestDelegate>
{ 
    NSArray *permissions;
    //Facebook *facebook;
    BOOL isConnected;
    UIBarButtonItem *logoutBtn;
    Facebook *facebook;
}

-(id) initWithJob:(Job *)aJob;
-(void) fillCell:(UITableViewCell*)cell InRow:(int)row inSection:(int)section;

@property(nonatomic, retain)Facebook *facebook;
//@property(nonatomic,retain) Job *job;
@end

