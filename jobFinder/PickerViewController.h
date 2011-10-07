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
}
@property(nonatomic, retain) UIPickerView *picker;
@end
