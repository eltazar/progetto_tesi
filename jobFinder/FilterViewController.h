//
//  FilterViewController.h
//  jobFinder
//
//  Created by mario greco on 30/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//@protocol FilterDelegate;

@interface FilterViewController : UITableViewController{
    NSArray *structureFromPlist;
    NSMutableDictionary *tableStructure;
    NSMutableArray *sections;
    NSString *plistName;
    UISwitch *aSwitch;
    
    NSMutableArray *selectedCells;
    
}
@property(nonatomic,retain) NSString *plistName;
@property(nonatomic, retain) NSArray *structureFromPlist;
@property(nonatomic, retain) NSMutableDictionary *tableStructure;
@property(nonatomic, retain) NSMutableArray *sections;
//@property(nonatomic,assign) id<FilterDelegate> filtDelegate;

-(id) initWithPlist:(NSString *)plist;
-(void)switchChanged;
@end


//@protocol FilterDelegate <NSObject>

//-(void)didSelectedFilterFromTable:(NSString*)filter;
//@end