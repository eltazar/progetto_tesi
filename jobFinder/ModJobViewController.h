//
//  ModJobViewController.h
//  jobFinder
//
//  Created by mario greco on 02/01/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RootJobViewController.h"
#import "SectorTableViewController.h"

@protocol ModJobViewControllerDelegate;

@interface ModJobViewController : RootJobViewController<UITextFieldDelegate, UITextViewDelegate, SectorTableDelegate>{
    UISegmentedControl *segmentedCtrl;
    id<ModJobViewControllerDelegate> delegate;
}
@property(nonatomic, assign) id<ModJobViewControllerDelegate> delegate;

-(void)fillCell: (UITableViewCell *)cell rowDesc:(NSDictionary *)rowDesc;
-(id)initWithJob:(Job*)theNewJob;
-(void)cancelBtnClicked:(id)sender;
@end

@protocol ModJobViewControllerDelegate <NSObject>

-(void)didDeletedJob:(id)sender;
@end