//
//  CreditsViewController.h
//  jobFinder
//
//  Created by mario greco on 26/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface CreditsViewController : UITableViewController<MFMailComposeViewControllerDelegate>{
    NSArray *sectionDescripition;
    NSArray *sectionData;
}

@end
