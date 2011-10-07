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
#import "CellCategory.h"

@interface TextFieldCell : UITableViewCell /*<UITextFieldDelegate>*/{
    UITextField *textField;
    NSString *dataKey;

}
@property (nonatomic, retain) NSString *dataKey;
@property (nonatomic, retain) UITextField *textField;

//// Imposta il valore del controllo gestito (TextField, ...)
//-(void) setControlValue:(id)value;
//
//// Legge il valore dal controllo
//-(id) getControlValue;
//
//// Helper per l'invio della notifica di fine editing
//-(void)postEndEditingNotification;


-(void) setDelegate:(id<UITextFieldDelegate>)delegate;

//- (NSString *) data;

@end
