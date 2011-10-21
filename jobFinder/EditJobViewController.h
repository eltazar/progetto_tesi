//
//  EditJobViewController.h
//  jobFinder
//
//  Created by mario greco on 03/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RootJobViewController.h"
#import "SectorTableViewController.h"
//@protocol PassDataCollectedDelegate;

@interface EditJobViewController : RootJobViewController <UITextFieldDelegate, UITextViewDelegate, SectorTableDelegate>{
//    Job *job;
//    id<PassDataCollectedDelegate> delegate;
    NSArray *fields;
    
}
@property(nonatomic,retain,readonly) NSArray *fields;//@property(nonatomic, retain, readonly) Job *job;
//@property(nonatomic, retain) PickerViewController *pickerView;
//@property(nonatomic, retain) id<PassDataCollectedDelegate> delegate;

-(void)fillCell: (UITableViewCell *)cell rowDesc:(NSDictionary *)rowDesc;

@end

/*
@protocol PassDataCollectedDelegate <NSObject>

-(void) setJobCollected:(Job *)job;

@end
*/