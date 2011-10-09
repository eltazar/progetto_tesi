//
//  TextDataEntryCell.m
//  jobFinder
//
//  Created by mario greco on 17/09/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TextFieldCell.h"

@implementation TextFieldCell

@synthesize textField, dataKey;

#pragma mark - setting cell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		// Configuro il textfield secondo la necessità
        self.selectionStyle = UITableViewCellSelectionStyleNone;
		self.textField = [[[UITextField alloc] initWithFrame:CGRectZero] autorelease];
		self.textField.clearsOnBeginEditing = NO;
		self.textField.textAlignment = UITextAlignmentLeft;
		self.textField.returnKeyType = UIReturnKeyDone;
		self.textField.font = [UIFont systemFontOfSize:17];
        [self.textField setAdjustsFontSizeToFitWidth:YES];
		self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
		self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;    
        
        //per far sparire la tastiera per qualsiasi textfield quando editing è finito
//        [self.textField addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];	
        
		[self.contentView addSubview:self.textField];
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
    
	CGRect labelRect = CGRectMake(self.textLabel.frame.origin.x,
                                  self.textLabel.frame.origin.y,
                                  self.contentView.frame.size.width * .35,
                                  self.textLabel.frame.size.height);
	[self.textLabel setFrame:labelRect];
    
	// Rect area del textbox
	CGRect rect = CGRectMake(self.textLabel.frame.origin.x + self.textLabel.frame.size.width  + 3,
							 12.0,
							 self.contentView.frame.size.width-(self.textLabel.frame.size.width + 3 + self.textLabel.frame.origin.x)-2,
							 25.0);
    
	[self.textField setFrame:rect];
}



//-(void) textFieldFinished: (id) sender
//{   //intenzionalmente vuoto
//   //    [sender resignFirstResponder];
//}



//-(void)postEndEditingNotification
//{
//	[[NSNotificationCenter defaultCenter] 
//	 postNotificationName:CELL_ENDEDIT_NOTIFICATION_NAME
//	 object:[(UITableView *)self.superview indexPathForCell: self]]; // Passa il proprio IndexPath
//	
//}
//-(void) setControlValue:(id)value
//{
////	self.textField.text = value;
//}
//
//-(id) getControlValue
//{
//	return self.textField.text;
//}
//
//
#pragma mark UITextFieldDelegate

//- (void)textFieldDidEndEditing:(UITextField *)txtField
//{
//	[self postEndEditingNotification];
//}

//- (NSString *) data
//{
//    return self.textField.text;
//}
//

-(void) setDelegate:(id<UITextFieldDelegate>)delegate
{
    self.textField.delegate = delegate; 
}
//
//-(id<UITextFieldDelegate>)delegate
//{
//    return self.textField.delegate;
//}

#pragma mark - Memory management

-(void) dealloc
{
    [super dealloc];
}




@end
