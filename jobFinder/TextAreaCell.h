//
//  TextAreaCell.h
//  jobFinder
//
//  Created by mario greco on 01/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseCell.h"

@interface TextAreaCell : BaseCell /*<UITextViewDelegate>*/{
    IBOutlet UITextView *textView;
}

@property (nonatomic, retain) IBOutlet UITextView *textView;

-(void) setDelegate:(id<UITextViewDelegate>)delegate;
@end