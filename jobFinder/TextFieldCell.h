//
//  TextDataEntryCell.h
//  jobFinder
//
//  Created by mario greco on 17/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//aggiunto 1 ottobre il protocollo e la define
//#define CELL_ENDEDIT_NOTIFICATION_NAME @"CellEndEdit"

#import <UIKit/UIKit.h>
#import "BaseCell.h"

@interface TextFieldCell : BaseCell{
    UITextField *textField;

}
@property (nonatomic, retain) UITextField *textField;


-(void) setDelegate:(id<UITextFieldDelegate>)delegate;

//- (NSString *) data;

@end
