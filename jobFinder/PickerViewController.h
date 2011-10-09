//
//  PickerViewController.h
//  jobFinder
//
//  Created by mario greco on 05/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickerViewController : UIViewController< UIPickerViewDelegate, UIPickerViewDataSource>
{
    NSArray *jobListCategory;
    NSString *jobCategory;
    
}
@property(nonatomic, retain) UIPickerView *picker;
@property(nonatomic, retain,readonly) NSString *jobCategory;
@end
