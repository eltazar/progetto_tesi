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
    NSDictionary *tableStructure;
    NSArray *sections;
    NSString *plistName;
}
@property(nonatomic, retain) NSArray *structureFromPlist;
@property(nonatomic, retain) NSDictionary *tableStructure;
@property(nonatomic, retain) NSArray *sections;
@property(nonatomic,readonly) NSString *selectedCell;
//@property(nonatomic,assign) id<FilterDelegate> filtDelegate;

-(id) initWithPlist:(NSString *)plist;
@end

@protocol SectorTableDelegate <NSObject>

-(void)receiveSectorFromTable:(NSString*)jobSector;
@end

//@protocol FilterDelegate <NSObject>

//-(void)didSelectedFilterFromTable:(NSString*)filter;
//@end