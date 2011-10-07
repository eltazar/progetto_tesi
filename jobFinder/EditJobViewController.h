//
//  EditJobViewController.h
//  jobFinder
//
//  Created by mario greco on 03/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootJobViewController.h"
#import "TextFieldCell.h"
#import "TextAreaCell.h"
#import "Job.h"
#import "PickerViewController.h"
#import "CellCategory.h"

//@protocol PassDataCollectedDelegate;

@interface EditJobViewController : RootJobViewController <UITextFieldDelegate, UITextViewDelegate, UIActionSheetDelegate>{
    Job *job;
//    id<PassDataCollectedDelegate> delegate;
    PickerViewController *pickerView;
    UIActionSheet *actionSheet;
    
}
@property(nonatomic, retain, readonly) Job *job;
//@property(nonatomic, retain) PickerViewController *pickerView;
//@property(nonatomic, retain) id<PassDataCollectedDelegate> delegate;


@end

/*
@protocol PassDataCollectedDelegate <NSObject>

-(void) setJobCollected:(Job *)job;

@end
*/