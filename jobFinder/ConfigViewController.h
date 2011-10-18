//ConfigViewController.h
//  jobFinder
//
//  Created by mario greco on 29/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TextFieldCell.h"
#import <MessageUI/MessageUI.h>



@interface ConfigViewController : UITableViewController <UITableViewDataSource, UITextFieldDelegate, MFMailComposeViewControllerDelegate>{
    
    NSArray *sectionDescripition;
    NSArray *sectionData;
    NSString *street;
    NSString *city;
    NSString *province;
    //Coordinate 
}
@end
