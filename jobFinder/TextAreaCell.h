//
//  TextAreaCell.h
//  jobFinder
//
//  Created by mario greco on 01/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CellCategory.h"

@interface TextAreaCell : UITableViewCell /*<UITextViewDelegate>*/{
    IBOutlet UITextView *textView;
    NSString *dataKey;

}

@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) NSString *dataKey;

-(void) setDelegate:(id<UITextViewDelegate>)delegate;
@end