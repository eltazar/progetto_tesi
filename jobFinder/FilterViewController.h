//
//  FilterViewController.h
//  jobFinder
//
//  Created by mario greco on 30/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FilterViewController : UIViewController <UITableViewDataSource>{
    NSArray *structureForSwitchTable;
    NSMutableDictionary *tableStructureForSwitchTable;
    NSMutableArray *sectionsForSwitchTable;
    UISwitch *aSwitch;
    
    NSArray *indices;

    UIView *mainView;
    UITableView *switchTable;
    UITableView *contentTable;
    
}

@property(nonatomic, retain) IBOutlet UITableView *switchTable;
@property(nonatomic ,retain) IBOutlet UITableView *contentTable;
@property(nonatomic, retain) IBOutlet UIView *mainView;

@property(nonatomic, retain) NSArray *indeces;
@property(nonatomic,retain) NSMutableArray *selectedCells;

@property(nonatomic, retain) NSArray *structureForContentTable;
@property(nonatomic, retain) NSMutableDictionary *tableStructureForContentTable;
@property(nonatomic, retain) NSMutableArray *sectionsForContentTable;


@property(nonatomic, retain) NSArray *structureForSwitchTable;
@property(nonatomic, retain) NSMutableDictionary *tableStructureForSwitchTable;
@property(nonatomic, retain) NSMutableArray *sectionsForSwitchTable;


@end